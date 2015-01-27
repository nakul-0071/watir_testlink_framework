require "watir_testlink_framework/version"
require 'rspec/core/rake_task'
require 'date'
require 'yaml'
require 'testlink_rspec_utils'
require 'rspec_testlink_formatters'
require 'test_linker'

spec = Gem::Specification.find_by_name 'watir_testlink_framework'
Dir.glob("#{spec.gem_dir}/lib/tasks/*.rake").each { |r| import r }

raise "Fatal: config.yml is missing." unless File.exists?('config.yml')

$config = YAML.load_file('config.yml')

#TODO TL BuildPrefixName
#TODO report back
#TODO exit 1 when failing
module WatirTestlinkFramework
  class TestLinkPlan

    def self.testlinkplanconnection
      server = $config['testlink']['xmlrpc_url']
      dev_key = $config['testlink']['apikey']
      return TestLinker.new(server, dev_key)
    end

    def self.planid_by_name(tl,name)
      plan_id = tl.test_plan_by_name($config['testlink']['project'], name)
      return plan_id[0][:id]
    end

    #plans_string comma seperated string with plans
    def self.run_plan_cases(plans_string, spectask='spec', dryrun=false)

      tl = self.testlinkplanconnection
      plans = plans_string.split(';')

      plans.each do | plan |

        plan_id = self.planid_by_name(tl, plan.strip)
        test_cases = tl.test_cases_for_test_plan(plan_id)

        #create new build
        buildname = "watirbuild_#{Time.new}"
        tl.create_build(plan_id, buildname, 'created by watir_testlink_framework')

        if $config['testlink'].has_key?("multi_env") && $config['testlink']['multi_env'] != 0
          $config['testlink']['testplans'][plan.strip].each do | envname, envarr |

            envstr = make_env_string(envarr)
            self.execute_cases(tl, envstr, spectask, test_cases, dryrun)
            self.report_cases(tl, plan_id, test_cases, envstr) if spectask=='junit' && !dryrun

          end

        else
          envstr = make_env_string($config['testlink']['testplans'][plan.strip])
          self.execute_cases(tl, envstr, spectask, test_cases, dryrun)
          self.report_cases(tl, plan_id, test_cases, envstr) if spectask=='junit' && !dryrun
        end

      end

    end

    def self.execute_cases(tl, envstr,spectask, test_cases,dryrun)
      test_cases.each do |tc|

        tc_customfield = tl.test_case_custom_field_design_value(tl.project_id($config['testlink']['project']),
                                                                tc[1][0]['full_external_id'], 
                                                                tc[1][0]['version'].to_i,
                                                                'RSPEC CASE ID',{:details=>''})

        exec_string = "#{envstr}bundle exec rake testlink:#{spectask} SPEC_OPTS=\"-e #{tc_customfield}\""
        if dryrun
          puts exec_string
        else
          system exec_string
        end
      end
    end

    def self.make_env_string(envarr)
      envstr=''
      envarr.each do | varname,varvalue|
        envstr+= "#{varname.upcase}='#{varvalue}' "
      end
      return envstr
    end

    def self.report_cases(tl, plan_id, cases, envstring)
      cases_arr ={}
      require 'pp'
      Dir["reports/*.xml"].each do | report |
        case_arr = XmlSimple::xml_in(report)
        cases_arr[case_arr['testcase'][0]['name']] = case_arr
      end

      cases.each do | tc |
        tc_customfield = tl.test_case_custom_field_design_value(tl.project_id($config['testlink']['project']),
                                                                tc[1][0]['full_external_id'],
                                                                tc[1][0]['version'].to_i,
                                                                'RSPEC CASE ID',{:details=>''})
        if cases_arr.has_key?(tc_customfield)
          options = {}
          notes=''
          if cases_arr[tc_customfield]['failures'] == '0'
            status ='p'
          elsif cases_arr[tc_customfield]['failures'] == '1'
            notes +=  "Message: " + cases_arr[tc_customfield]['testcase'][0]['failure'][0]['message']
            notes += "\n"
            notes += "Type: " + cases_arr[tc_customfield]['testcase'][0]['failure'][0]['type']
            notes += "\n"
            notes += "Content: " + cases_arr[tc_customfield]['testcase'][0]['failure'][0]['content']
            notes += "\n"
            notes += "EnvString: " + envstring
            status ='f'
          else
            status = 'b'
          end

          options['notes'] = notes
          tl.report_test_case_result(plan_id, tc[0], status, options)
        end

      end
    end

  end
end





















