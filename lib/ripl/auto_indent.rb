require 'ripl'
require 'ripl/multi_line'
require 'coderay'

module Ripl
  module AutoIndent
    VERSION = '0.1.0'
    TPUT = {
      :sc   => `tput sc`,   # save current cursor position
      :cuu1 => `tput cuu1`, # move cursor upwards    to the original input line
      :cuf1 => `tput cuf1`, # move cursor rightwards to the original input offset
      :rc   => `tput rc`,   # return to normal cursor position
    }

    def before_loop
      super
      @current_indent = 0
    end

    def get_indent(buffer)
      indent = 0
      opening_tokens = %w[begin case class def for if module unless until while do {]
      closing_tokens = %w[end }]
      # parse each token
      buffer_tokens = CodeRay.scan(buffer, :ruby)
      buffer_tokens.each{ |token, kind|
        if kind == :reserved || kind == :operator
          if opening_tokens.include? token
            indent += 1
          elsif closing_tokens.include? token
            indent -= 1
          end
        end
      }
      # return a good value
      indent < 0 ? 0 : indent
    end

    def prompt
      @buffer ? config[:multi_line_prompt] + config[:auto_indent_space]*@current_indent : super
    end

    def rewrite_line(append_indents = 0)
      print TPUT[:sc] +
            TPUT[:cuu1] +
            prompt + 
            @input +
            config[:auto_indent_space]*append_indents +
            TPUT[:rc]
    end

    def eval_input(input)
      last_indent     = @current_indent
      @current_indent = get_indent(@buffer ? @buffer + input : input)

      if config[:auto_indent_rewrite] && @current_indent < last_indent
        rewrite_line last_indent - @current_indent
      end

      super # (@buffer ? @buffer + input : input)
    end
  end
end

Ripl::Shell.send :include, Ripl::AutoIndent

# default config
Ripl.config[:auto_indent_rewrite] = true
Ripl.config[:auto_indent_space]   = '  '
Ripl.config[:multi_line_prompt]   = '|  ' if !Ripl.config[:multi_line_prompt] ||
                                             Ripl.config[:multi_line_prompt] == '|    '

# J-_-L
