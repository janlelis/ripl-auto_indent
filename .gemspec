# -*- encoding: utf-8 -*-
require 'rubygems' unless defined? Gem
require File.dirname(__FILE__) + "/lib/ripl/auto_indent"
 
Gem::Specification.new do |s|
  s.name        = "ripl-auto_indent"
  s.version     = Ripl::AutoIndent::VERSION
  s.authors     = ["Jan Lelis"]
  s.email       = "mail@janlelis.de"
  s.homepage    = "http://github.com/janlelis/ripl-auto_indent"
  s.summary     = "A ripl plugin which indents your entered Ruby code."
  s.description = "This ripl plugin indents your multi-line Ruby input using coderay."
  s.required_rubygems_version = ">= 1.3.6"
  s.add_dependency 'ripl', '>= 0.3.1'
  s.add_dependency 'ripl-multi_line', '>= 0.2.3'
  s.add_dependency 'coderay', '~> 0.9'
  s.files = Dir.glob(%w[{lib,test}/**/*.rb bin/* [A-Z]*.{txt,rdoc} ext/**/*.{rb,c} **/deps.rip]) + %w{Rakefile .gemspec}
  s.extra_rdoc_files = ["README.rdoc", "LICENSE.txt"]
  s.license = 'MIT'
end
