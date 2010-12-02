require 'ripl'
require 'ripl/multi_line'
require 'coderay'
#require 'open3'

module Ripl
  module AutoIndent
    VERSION = '0.1.1'
    TPUT = {
      :sc   => `tput sc`,   # save current cursor position
      :cuu1 => `tput cuu1`, # move cursor on line upwards
      :rc   => `tput rc`,   # return to normal cursor position
    }

    def before_loop
      @current_indent = 0
      super
    end

    def get_indent(buffer)
      #syntax_ok = proc{ |code|
      #  Open3.popen3('ruby -c'){ |sin, sout, _|
      #    sin << code
      #    sin.close
      #    sout.read.chomp
      #  } == "Syntax OK"
      #}

      opening_tokens = %w[begin case class def for if module unless until while do {]
      closing_tokens = %w[end }]
      indent = 0
      # parse each token
      buffer_tokens = CodeRay.scan(buffer, :ruby)
      buffer_tokens.each{ |token, kind|
        if kind == :reserved || kind == :operator
          if opening_tokens.include? token
            # modifiers cause trouble - so guess, if it is intended as one 
            #  (because the current line has valid syntax)
            #next if %w[if unless until while].include?(token) && syntax_ok[ line ]

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
      last_indent     = @current_indent
      @current_indent = get_indent(@buffer ? @buffer*"\n" + "\n" + input : input)

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
