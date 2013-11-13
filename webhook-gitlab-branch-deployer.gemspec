# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "webhook-gitlab-branch-deployer"
  spec.version       = '0.0.1'
  spec.authors       = ["Krzysztof Tomczyk"]
  spec.email         = ["ktomczyk@power.com.pl"]
  spec.description   = %q{Gitlab webhook branch deployer}
  spec.summary       = %q{Automate git repository branch deployment}
  spec.homepage      = "http://www.power.com.pl"
  spec.license       = "GPL-3"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_dependency "json"
  spec.add_dependency "rack"
  spec.add_dependency "thin"
  spec.add_dependency "puppet"
  spec.add_dependency "daemons"
end

