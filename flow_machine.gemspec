# -*- encoding: utf-8 -*-
require File.expand_path('../lib/flow_machine/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Heinrich Klobuczek"]
  gem.email         = ["heinrich@mail.com"]
  gem.description   = %q{Simplified state machine for flexible view flow definition}
  gem.summary       = %q{Use this gem for applications where the view to be displayed cannot be statically determined, because it depends on the status of the user and various decisions he makes on his way.}
  gem.homepage      = "http://github.com/klobuczek/flow_machine"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "flow_machine"
  gem.require_paths = ["lib"]
  gem.version       = FlowMachine::VERSION
end
