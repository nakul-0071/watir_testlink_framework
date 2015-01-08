# Watir TestLink Framework

This is a test framework organically grew in the Lingewoud software
lab. It combines a lot of other fine software like Watir, TestLink,
Rspec, Rake, Junit etc.. to make it easy to run large sets of test
cases on different stages of sites.

The Watir TestLink Framework can be used be a developer on his
desktop but can also be easily integrated in a CI server like
Jenkins. (see: https://github.com/mipmip/jenkins-workflow-typo3)

Use it in your web project testing project.

Major Features:
- Provides TestLink RPC connection
- Run test plans from testlink
- Implements the Watir Page Object Pattern

Minor Features
- Web page screenshots
- Convert testlink requirements to rspec cases
- Export rspec cases to a testlink testcase xml file

## Compatibility

* Only tested with TestLink 1.9.13

## Installation

Add these lines to your application's Gemfile:

```ruby
# This is needed as long as turboladen didn't merge
gem 'test_linker', :git => 'https://github.com/mipmip/test_linker.git'
gem 'watir_testlink_framework'
```

And then execute:

    $ bundle

## Usage

Copy Rakefile.sample and config.yml.sample to your project dir.

Create a spec dir with naming like ```myfile_spec.rb```

Type ./bin/rake -T to list all rake commands. ATOW:

```bash
rake spec                                  # Run all specs with doc output
rake testlink:cases_import                 # Run all specs with xml output for cases import in testlink
rake testlink:plan[testplan]               # run plan by testplan name
rake testlink:plan_ci                      # run continuious intergration plan
rake testlink:plan_production              # run production testplan
rake testlink:req2spec[requirements_file]  # Creates a spec file with all cases from TestLink requirements export
rake testlink:spec                         # Run spec(s) with junit output
```

## Contributing

1. Fork it ( https://github.com/Lingewoud/watir_testlink_framework/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
