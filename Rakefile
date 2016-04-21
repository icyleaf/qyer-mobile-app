require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

require 'qma'

RSpec::Core::RakeTask.new(:spec)

task default: :spec

task :test do
  key = '75f4d21a3d4efbd9ba9217eb6989a35b'
  ipa_file = File.dirname(__FILE__) + '/spec/fixtures/apps/iphone.ipa'

  client = QMA::Client.new(key)
  client.config.external_host = 'http://localhost:3333/'
  ap client.upload(ipa_file, params: {
                                        name: '测试',
                                        identifier: 'com.test.qyer',
                                        device_type: 'iphone',
                                        release_version: '1.0',
                                        build_version: '1.0.0'
                                      })
end

task :parse do
  ipa_file = '/Users/wiiseer/Downloads/iBook_2.2.1_25_201603211208.ipa'

  app = QMA::App.parse(ipa_file)
  ap app
  # ap app.mobileprovision
  ap app.release_type
  ap app.metadata

  app = QMA::App.parse('/Users/wiiseer/Downloads/JX3ou_1.6_1.6_201604141430.ipa')
  ap app
  ap app.release_type
  # ap app.mobileprovision
  ap app.distribution_name
  ap app.metadata
end
