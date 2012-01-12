require 'ripl'
require 'ripl/multi_line'
require 'ruby_indentation'

module Ripl
  module AutoIndent
    VERSION = '0.2.0'
    TPUT = {
      :cuu1 => "\e[A", # up
      :sc   => "\e7",  # save
      :rc   => "\e8",  # load
    }

    def before_loop
      @current_indent = 0
      super
    end

    def prompt
      @buffer ? super + config[:auto_indent_space]*@current_indent : super
    end

    def rewrite_line(append_indents = 0)
      print_method = defined?(Ripl::ColorStreams) ? :real_write : :write
      $stdout.send print_method,
        TPUT[:sc] +
        TPUT[:cuu1] +
        prompt + 
        @input +
        config[:auto_indent_space]*append_indents +
        TPUT[:rc]
    end

    def loop_eval(input)
      last_indent     = ( @current_indent ||= 0 )
      @current_indent = RubyIndentation[ @buffer ? @buffer*";"+";"+input : input ]

      if config[:auto_indent_rewrite] && @current_indent < last_indent
        rewrite_line last_indent - @current_indent
      end

      super # (@buffer ? @buffer + input : input)
    end
  end
end

Ripl::Shell.include Ripl::AutoIndent

# default config
Ripl.config[:auto_indent_rewrite] = true  if  Ripl.config[:auto_indent_rewrite].nil?
Ripl.config[:auto_indent_space] ||= '  '

# J-_-L
