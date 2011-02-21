require 'ripl'
require 'ripl/multi_line'
require 'coderay'
require 'set'

module Ripl
  module AutoIndent
    VERSION = '0.1.3'
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
      opening_and_modifier_tokens = %w[if unless until while].to_set
      opening_tokens              = %w[begin case class def for module do {].to_set
      closing_tokens              = %w[end }].to_set
      separator                   = [';', :operator]
      indent                      = 0

      # parse each token
      buffer_tokens = [separator] + CodeRay.scan(buffer, :ruby).select{|_, kind|
        kind != :space
      }

      buffer_tokens.each_cons(2){ |(*old_pair), (token, kind)|
        if kind == :reserved || kind == :operator
          # modifiers cause trouble, so
          #  fix it in 9/10 cases
          if opening_tokens.include?(token) ||
             opening_and_modifier_tokens.include?(token) &&
               ( old_pair == separator || old_pair == ['=', :operator ] )
            indent += 1
          elsif closing_tokens.include?(token)
            indent -= 1
          end
        end
      }
      # return a good value
      indent < 0 ? 0 : indent
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
      @current_indent = get_indent( @buffer ? @buffer*";"+";"+input : input )

      if config[:auto_indent_rewrite] && @current_indent < last_indent
        rewrite_line last_indent - @current_indent
      end

      super # (@buffer ? @buffer + input : input)
    end
  end
end

Ripl::Shell.send :include, Ripl::AutoIndent

# default config
Ripl.config[:auto_indent_rewrite] = true  if  Ripl.config[:auto_indent_rewrite].nil?
Ripl.config[:auto_indent_space] ||= '  '

# J-_-L
