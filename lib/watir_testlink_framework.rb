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

    def self.casesbyplan(tl,plan)
      plan_id = tl.test_plan_by_name($config['testlink']['project'], plan)
      return tl.test_cases_for_test_plan(plan_id[0][:id])
    end

    #plans_string comma seperated string with plans
    def self.run_plan_cases(plans_string, spectask='spec', dryrun=false)

      tl = self.testlinkplanconnection

      plans = plans_string.split(';')

      plans.each do | plan |
        test_cases = self.casesbyplan(tl,plan.strip)
        if $config['testlink'].has_key?("multi_env") && $config['testlink']['multi_env'] != 0
          $config['testlink']['testplans'][plan.strip].each do | envname, envarr |
            envstr = make_env_string(envarr)
            self.execute_cases(tl, envstr,spectask,test_cases,dryrun)
          end
        else
          envstr = make_env_string($config['testlink']['testplans'][plan.strip])
          self.execute_cases(tl, envstr,spectask, test_cases,dryrun)
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

  end
end





















