# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "active_record_calculator/version"

Gem::Specification.new do |s|
  s.name        = "active_record_calculator"
  s.version     = ActiveRecordCalculator::VERSION::STRING
  s.authors     = ["Grady Griffin"]
  s.email       = ["gradyg@izea.com"]
  s.homepage    = "https://github.com/thegboat/active_record_calculator"
  s.summary     = %q{ActiveRecord Calculations done faster}
  s.description = %q{active_record_calculator does groupable aggregate functions in one sql call for better performance}

  s.rubyforge_project = "active_record_calculator"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
  if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    s.add_runtime_dependency('activerecord', "<3.0.0")
    s.add_development_dependency("rspec")
    s.add_development_dependency("mysql")
  else
    s.add_dependency('activerecord', "<3.0.0")
    s.add_development_dependency("rspec")
    s.add_development_dependency("mysql")
  end
end
