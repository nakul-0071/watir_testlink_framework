desc 'Run all specs with doc output'
RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = "--format documentation"
  t.pattern = '**/*_spec.rb'
end
