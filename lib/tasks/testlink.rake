namespace :testlink do
  desc 'run continuious intergration plan'
  task :plan_ci do
    WatirTestlinkFramework::TestLinkPlan::run_plan_cases $config['testlink']['testplan_ci']
  end

  desc 'run production testplan'
  task :plan_production do
    WatirTestlinkFramework::TestLinkPlan::run_plan_cases $config['testlink']['testplan_production']
  end

  desc 'run plan by testplan name'
  task :plan,[:testplan] do |t, args|
    WatirTestlinkFramework::TestLinkPlan::run_plan_cases args[:testplan]
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

  desc 'Run spec(s) with junit output'
  RSpec::Core::RakeTask.new(:spec) do |t|

    d = DateTime.now
    newTarget = d.strftime("%Y%m%dT%H%M%S")

    Dir.mkdir 'reports' unless File.exists?('reports')

    t.rspec_opts = "--format RspecTestlinkJunitformatter -r rspec_testlink_formatters --out reports/SPEC#{newTarget}-out.xml"
    t.pattern = '**/*_spec.rb'
  end
end
