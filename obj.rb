# obj.rb
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
require 'rubygems'
require 'json'

module FlyingRobots
   
class Obj
  @@direct_types = [
    Array,
    Bignum,
    FalseClass,
    Fixnum,
    Float,
    Hash,
    Integer,
    String,
    TrueClass
  ]

public 
  #--------------------------------------------------------------------------
  def self.to_hash(object, options = {})
    object.instance_variables.inject({}) { |h, ivar|
      key = (options[:symbolic_keys] == true) ? ivar[1..-1].to_sym : ivar[1..-1].to_s
      value = object.instance_variable_get(ivar)
      if @@direct_types.include? value.class
        h[key] = value
      else
        h[key] = to_hash value
      end
      h
    }
  end

  #--------------------------------------------------------------------------
  def self.from_hash(object, h)
    h.each_pair { |key, value|
      key_sym = key.to_sym
      if object.instance_variable_defined? key_sym
        if value.class == Hash
          ivar = object.instance_variable_get key_sym
          if @@direct_types.include? ivar.class
            object.instance_variable_set key_sym, value
          else
            from_hash object.instance_variable_get(key_sym), value
          end
        end
      else
        type = object.class
        raise "Unrecognized key '#{key}' for objectect of type '#{type}'"
      end
    }
    object
  end

  #--------------------------------------------------------------------------
  def self.to_json(object, options = {})
    if object.respond_to? :to_json
      object.to_json options
    else
      h = to_hash object
      if options[:pretty] == true
        JSON.pretty_generate h
      else
        JSON.generate h
      end
    end
  end

  #--------------------------------------------------------------------------
  def self.from_json(object, json_str)
    if object.respond_to? :from_json
      object.from_json json_str
    else
      from_hash object, JSON.load(json_str)
    end
  end


end

end

