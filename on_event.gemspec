# -*- encoding: utf-8 -*-
require File.expand_path('../lib/on_event/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Brendon Murphy"]
  gem.email         = ["xternal1+github@gmail.com"]
  gem.description   = %q{Build callback chains for named events.}
  gem.summary       = gem.description
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "on_event"
  gem.require_paths = ["lib"]
  gem.version       = OnEvent::VERSION
end
