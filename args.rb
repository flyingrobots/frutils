# args.rb
# ------------------------------------------------------------------------------
# The MIT License (MIT)
# 
# Copyright (c) 2013 James Ross
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
# ------------------------------------------------------------------------------
script_dir = File.expand_path File.dirname(__FILE__)
require File.join script_dir, 'types.rb'
require File.join script_dir, 'log.rb'

# TODO JSON is used to pretty print arrays and hashes - add this feature to Log
require 'rubygems'
require 'json'

module FlyingRobots
  class Args
  public
    def initialize
      @logger = Log.new({ :name => "Args" })
      @flags = {}
      @options = {}
      @types = Types.new
      _describe_flag "help", "Displays the help message.", {}
    end

    def describe_flag(name, description, options = {})
      raise "The option 'help' is reserved and cannot be overwritten." if name == "help"
      flag = _describe_flag name, description, options
      @logger.debug "Args: Option '#{name}' => #{JSON.pretty_generate(flag)}"      
    end

    def print_help
      puts "== About =="
      puts "Prepends a file header containing a licence to the specified files."
      puts ""
      puts "== Useage =="
      puts "  % ./licenser.rb [options]"
      puts ""
      puts "== Options =="
      @flags.values.each() { |f|
        puts "#{f[:short]} OR #{f[:long]}"
        puts "  #{f[:description]}"
        puts "  Default: #{f[:default]}" unless f[:required]
        puts "  Note: This is a required option." if f[:required]
        puts "  Note: This option accepts multiple values of type '#{f[:type]}'." if f[:multi]
        puts ""
      }
      puts "== Examples =="
      puts "  A single file:"
      puts "    licenser.rb -f foo.cpp"
      puts ""
      puts "  Using a specific license file:"
      puts "    licenser.rb -f foo.coffee -l /path/to/some/license.txt"
      puts ""
    end

    def parse(args)
      context = CONTEXT_FLAG
      flag = nil
      args.each_with_index { |arg, index|
        @logger.debug "Args: arg[#{index}] = #{arg}"
        next_arg = args.size > index ? args[index + 1] : nil
        next_arg_is_value = next_arg ? !next_arg.start_with?("-") : false
        case context
        when CONTEXT_FLAG
          flag = _parse_flag arg
          raise "Unknown option '#{arg}'. See help for available options (-h or --help)." if flag == nil
          name = flag[:name]
          type = flag[:type]
          if type == :boolean
            @options[name.to_sym] = true
            @logger.debug "Args: @options[#{name}] << 'true'"
          else
            context = CONTEXT_VALUE
            if next_arg == nil or not next_arg_is_value
              raise "Option '#{name}' requires #{(flag[:multi] ? "at least one" : "a")} value of type '#{type}'."
            end
          end
        when CONTEXT_VALUE
          type = flag[:type]
          value = _parse_value arg, type
          name = flag[:name]
          @options[name.to_sym] << value
          @logger.debug "Args: @options[#{name}] << #{value}."
          if next_arg_is_value
            if not flag[:multi]
              raise "Option '#{name}' expects a single value of type '#{type}'."
            end
          else
            context = CONTEXT_FLAG
          end
        end
      }
      @logger.debug "@options = #{JSON.pretty_generate(@options)}"
      raise "No options were specified. See help for useage (-h or --help)." if @options.size == 0
      _check_for_required_options
      @options
    end
 
  private
    CONTEXT_FLAG = 0
    CONTEXT_VALUE = 1

    def _parse_flag(arg)
      match = arg.match(/^(-*)[a-zA-Z0-9]*/)
      if match == nil or match.captures == nil
        raise "Malformed option '#{arg}'. See help for useage (-h or --help)."
      else
        flag_header = match.captures[0]
        short_form = flag_header.size < 2
        @flags.values.find { |f| short_form ? f[:short] == arg : f[:long] == arg }
      end
    end

    def _parse_value(arg, type)
      @types.string_to_object(type, arg)
    end

    def _check_for_required_options
      return if @options[:help]
      reqs = @flags.values.select { |f| f[:required] == true }
      reqs.each { |f| raise "Missing required option '#{f[:long]}'. See help for details (-h or --help)." if @options[f[:name]] == nil }
    end

    def _describe_flag(name, description, options)
      name_as_sym = name.to_sym
      flag = {
        :name => name_as_sym,
        :short => options.key?(:short) ? options[:short] : "-" + name.chars.first,
        :long => options.key?(:long) ? options[:long] : "--" + name,
        :description => description,
        :default => options.key?(:default) ? options[:default] : nil,
        :type => options.key?(:type) ? options[:type] : :boolean,
        :multi => options[:multi] == true,
        :required => options[:required] == true
      }
      type = flag[:type]
      if @types.class_of(type) == nil
        raise "Option #{name} has a type '#{type}', which is an unsupported type. (Must be ':boolean', ':int', ':float', or ':string')."
      end
      flag[:default] = @types.default_value(type) if flag[:default] == nil
      default_value_type = @types.type_of flag[:default].class
      raise "Option #{name} has a default value of type '#{default_value_type}', which does not match the specified type '#{type}'." if options.key?(:default) and default_value_type != type
      raise "Option #{name} has a type '#{default_value_type}', which is not allowed for options that accept multiple values." if type == :boolean and flag[:multi]
      @flags[name_as_sym] = flag
      if not flag[:required]
        @options[name_as_sym] = []
        @options[name_as_sym] << flag[:default]
      end
      flag
    end
 
  end
end
