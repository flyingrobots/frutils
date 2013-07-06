# log.rb
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
file_dir = File.expand_path File.dirname(__FILE__)
require File.join file_dir, 'obj.rb'

require 'rubygems'
require 'json'

module FlyingRobots

class Log
public
  #--------------------------------------------------------------------------
  VOLUME_TRACE = 0
  VOLUME_DEBUG = 1
  VOLUME_INFO  = 2
  VOLUME_WARN  = 3
  VOLUME_ERROR = 4
  VOLUME_MUTE  = 5

  #--------------------------------------------------------------------------
  def initialize(options = {})
    @debug = options[:debug]
    @name = options[:name]
    @volume = options[:volume] || VOLUME_WARN
  end

  #--------------------------------------------------------------------------
  def trace(message, *rest)
    _log VOLUME_TRACE, message, rest
  end

  #--------------------------------------------------------------------------
  def debug(message, *rest)
    _log VOLUME_DEBUG, message, rest
  end

  #--------------------------------------------------------------------------
  def info(message, *rest)
    _log VOLUME_INFO, message, rest
  end

  #--------------------------------------------------------------------------
  def warn(message, *rest)
    _log VOLUME_WARN, message, rest
  end

  #--------------------------------------------------------------------------
  def error(message, *rest)
    _log VOLUME_ERROR, message, rest
  end

  #--------------------------------------------------------------------------
  def exception(e)
    error "(exception)", e.inspect, e.backtrace
  end

private
  #----------------------------------------------------------------------------
  def _log(volume, message, *rest)
    return if volume < @volume
    volume_s = _volume_to_s @volume
    name = @name == nil ? "" : "#{@name} "
    stream = volume > VOLUME_WARN ? $stderr : $stdout
    str = _object_to_s message
    if rest.size > 0
      rest[0].each { |v| str.concat " #{_object_to_s(v)}" }
    end
    stream.puts name + _volume_to_s(volume) + str
  end
  
  #--------------------------------------------------------------------------
  def _volume_to_s(volume)
    case volume
    when VOLUME_TRACE
      "TRACE "
    when VOLUME_DEBUG
      "DEBUG "
    when VOLUME_INFO
      "INFO  "
    when VOLUME_WARN
      "WARN  "
    when VOLUME_ERROR
      "ERROR "
    else
      raise "Unknown volume '#{volume.to_s}'."
    end
  end

  #--------------------------------------------------------------------------
  def _object_to_s(object)
    case object
    when Array, Hash
      JSON.generate object
    when Bignum, FalseClass, Fixnum, Float, Integer, NilClass, String, TrueClass
      object.to_s
    else
      JSON.generate Obj.to_hash(object)
    end
  end

end

end

