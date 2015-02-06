# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mathjax/renderer/version'

Gem::Specification.new do |spec|
  spec.name          = "mathjax-renderer"
  spec.version       = Mathjax::Renderer::VERSION
  spec.authors       = ["sashee"]
  spec.email         = ["gsashee@gmail.com"]
  spec.summary       = %q{Summary}
  spec.description   = %q{Description}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"

  spec.add_dependency "rails-assets-MathJax"
  spec.add_dependency "nokogiri"
  spec.add_dependency "concurrent-ruby"
  spec.add_dependency "selenium-webdriver"
  spec.add_dependency "capybara"
  spec.add_dependency "chromedriver-helper"
  spec.add_dependency "chunky_png"
  spec.add_dependency "headless"
end
