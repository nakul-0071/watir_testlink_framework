task default: %w[testlink:run_default_plan]
namespace :testlink do
  desc 'run default testplan'
  task :run_default_plan do

    if $config['testlink']['testplans'].keys[0].nil?
      raise "No valid testplan defined in config.yml"
    end

    WatirTestlinkFramework::TestLinkPlan::run_plan_cases $config['testlink']['testplans'].keys[0], 'spec'
  end

  desc 'run continuious intergration plan'
  task :plan_ci do
    WatirTestlinkFramework::TestLinkPlan::run_plan_cases $config['testlink']['testplan_ci'], 'junit'
  end

  desc 'run production testplan'
  task :plan_production do
    WatirTestlinkFramework::TestLinkPlan::run_plan_cases $config['testlink']['testplan_production'], 'junit'
  end

  desc 'run plan by testplan name'
  task :run_plan,[:testplan] do |t, args|
    WatirTestlinkFramework::TestLinkPlan::run_plan_cases args[:testplan], 'spec'
  end

  desc 'dry run plan by testplan name, show cli cmd'
  task :dry_run_plan,[:testplan] do |t, args|
    WatirTestlinkFramework::TestLinkPlan::run_plan_cases args[:testplan], 'spec', true
  end

  desc 'run plan by testplan name, format junit'
  task :run_plan_junit,[:testplan] do |t, args|
    WatirTestlinkFramework::TestLinkPlan::run_plan_cases args[:testplan], 'junit'
  end

  desc 'dry run plan by testplan name, show cli cmd, format junit'
  task :dry_run_plan_junit,[:testplan] do |t, args|
    WatirTestlinkFramework::TestLinkPlan::run_plan_cases args[:testplan], 'junit', true
  end

  desc 'Creates a spec file with all cases from TestLink requirements export'
  task :req2spec,[:requirements_file] do |t, args|

    STDOUT.puts "Enter Project Code e.g.: linge-0666 intranet"
    project = STDIN.gets.strip

    fileout  = $config['application']+project+"_spec.rb"
    fileout =  fileout.gsub(/[^\w\.\-]/,"_")

    convert = TestlinkRspecUtils::Convert.new
    convert.requirements_to_cases($config['application'],project, args[:requirements_file], 'spec/'+fileout)
  end

  desc 'Run all specs with xml output for cases import in testlink'
  RSpec::Core::RakeTask.new(:cases_import) do |t|
    t.rspec_opts = "--format RspecTestlinkExportCases -r rspec_testlink_formatters --out tc-testlink.xml"
    t.pattern = '**/*_spec.rb'

    print "\nwrote output to tc-testlink.xml\n\n"
  end

  desc 'Run spec(s) with doc output'
  RSpec::Core::RakeTask.new(:spec) do |t|
    t.rspec_opts = "--format documentation"
    t.pattern = '**/*_spec.rb'
  end

  desc 'Run spec(s) with junit output'
  RSpec::Core::RakeTask.new(:junit) do |t|

    d = DateTime.now
    newTarget = d.strftime("%Y%m%dT%H%M%S")

    Dir.mkdir 'reports' unless File.exists?('reports')

    t.rspec_opts = "--format RspecTestlinkJunitformatter -r rspec_testlink_formatters --out reports/SPEC#{newTarget}-out.xml"
    t.pattern = '**/*_spec.rb'
  end
end
