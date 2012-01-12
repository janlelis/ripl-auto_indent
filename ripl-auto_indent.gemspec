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
  s.description = "This ripl plugin indents your multi-line Ruby input using ruby_indentation gem."
  s.required_rubygems_version = ">= 1.3.6"
  s.add_dependency 'ripl', '>= 0.6.0'
  s.add_dependency 'ripl-multi_line', '>= 0.3.0'
  s.add_dependency 'ruby_indentation', '>= 0.2.0'
  s.files = Dir.glob(%w[{lib,test}/**/*.rb bin/* [A-Z]*.{txt,rdoc} ext/**/*.{rb,c} **/deps.rip]) + %W[Rakefile #{__FILE__}]
  s.extra_rdoc_files = ["README.rdoc", "LICENSE.txt"]
  s.license = 'MIT'
end
