# encoding: UTF-8
Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'spree_sunspot'
  s.version     = '0.1.0'
  s.summary     = 'Use Sunspot as search engine in Spree applications'
  s.description = 'Use Sunspot for searching and filtering products in Spree applications'
  s.required_ruby_version = '>= 1.8.7'

  s.author            = 'Chandramohan Rangaswamy'
  s.email             = 'chandru@simplelife.in'
  s.homepage          = 'http://www.simplelife.in'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_path = 'lib'
  s.requirements << 'none'

  s.add_dependency 'spree_core', '>= 1.0.0'
  s.add_dependency 'sunspot_rails', '>= 1.3.0'

  s.add_development_dependency 'capybara', '1.0.1'
  s.add_development_dependency 'factory_girl'
  s.add_development_dependency 'ffaker'
  s.add_development_dependency 'rspec-rails',  '~> 2.8'
  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'sunspot_solr', '>= 1.3.0'
end
