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
module FlyingRobots

  class Log
  public

    VOLUME_TRACE = 0
    VOLUME_DEBUG = 1
    VOLUME_INFO  = 2
    VOLUME_WARN  = 3
    VOLUME_ERROR = 4
    VOLUME_MUTE  = 5

    def initialize(options = {})
      @debug = options[:debug]
      @name = options[:name]
      @volume = options[:volume] || VOLUME_WARN
    end

    def trace(message)
      _log VOLUME_TRACE, message 
    end

    def debug(message)
      _log VOLUME_DEBUG, message
    end

    def info(message)
      _log VOLUME_INFO, message
    end

    def warn(message)
      _log VOLUME_WARN, message
    end

    def error(message)
      _log VOLUME_ERROR, message
    end

    def exception(e)
      error e.to_s
      error e.backtrace
    end

  private

    def _log(volume, message)
      return if volume < @volume
      name = @name.to_s
      volume_s = _volume_to_s @volume
      stream = volume > VOLUME_WARN ? $stderr : $stdout
      stream << name ? "(#{name}) " : "" << volume_s << " " << message.to_s
    end
    
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
        raise "Unknown volume '#{volume}'."
      end
    end

  end

end

