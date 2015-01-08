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

module WatirTestlinkFramework
  class TestLinkPlan

    def self.run_plan_cases(plan)
      #TL URL to test
      #TL BuildPrefixName
      # report back
      server = $config['testlink']['xmlrpc_url']
      dev_key = $config['testlink']['apikey']
      tl_project = $config['testlink']['project']

      tl = TestLinker.new(server, dev_key)

      project_id = tl.project_id tl_project
      plan_id = tl.test_plan_by_name(tl_project, plan)

      test_cases = tl.test_cases_for_test_plan(plan_id[0][:id])
      test_cases.each do |tc|
        tc_customfield = tl.test_case_custom_field_design_value(project_id, tc[1][0]['full_external_id'], tc[1][0]['version'].to_i, 'RSPEC CASE ID',{:details=>''})

        #TODO exit 1 when failing
        system("bundle exec rake testlink:spec SPEC_OPTS=\"-e #{tc_customfield}\"")
      end
    end
  end
end
