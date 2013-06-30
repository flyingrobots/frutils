# arg_types.rb
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
module FlyingRobots

require 'rubygems'
require 'json'
  
class Types
  # -------------------------------------------------------------------------
  def initialize
    @type_to_class = {
      :boolean => { 
        :class => :boolean, 
        :default => false, 
        :string_to_object => lambda { |x| x == "true" } 
      },
      :int => { 
        :class => Integer.class, 
        :default => 0, 
        :string_to_object => lambda { |x| x.to_i } 
      },
      :float => { 
        :class => Float.class, 
        :default => 0.0, 
        :string_to_object => lambda { |x| x.to_f } 
      },
      :string => { 
        :class => String.class, 
        :default => "", 
        :string_to_object => lambda { |x| x } 
      }
    }
    @class_to_type = {
      TrueClass => :boolean,
      FalseClass => :boolean,
      Integer => :int,
      Float => :float,
      String => :string
    }
  end

  # -------------------------------------------------------------------------
  def type_of(object)
    object_class = object.class
    @class_to_type[object_class]
  end
  
  # -------------------------------------------------------------------------
  def class_of(type)
    if type == :boolean
      :boolean # the class can't be determined without testing the value, which is unavailable
    else
      class_info = @type_to_class[type.to_sym]
      class_info == nil ? nil : class_info[:class]
    end
  end
  
  # -------------------------------------------------------------------------
  def default_value(type)
    class_info = @type_to_class[type.to_sym]
    class_info == nil ? nil : class_info[:default]
  end
  
  # -------------------------------------------------------------------------
  def string_to_object(type, str)
    class_info = @type_to_class[type.to_sym]
    raise "Unrecognized type '#{type}'." if class_info == nil
    raise "No string to object transformation defined for type '#{type}'." if class_info[:string_to_object] == nil
    class_info[:string_to_object].call str
  end
end

end
