# app.rb
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
require File.join file_dir, 'args.rb'
require File.join file_dir, 'log.rb'

module FlyingRobots

class Application
public
  #----------------------------------------------------------------------------
  def initialize(argv, flags = [])
    @log = Log.new({
      :name => "App",
      # :volume => Log::VOLUME_DEBUG
    })
    @options = _parse_args(argv, flags)
    @log.debug @options
  end

  #----------------------------------------------------------------------------
  def run(&block)
    yield @options
  rescue => e
    @log.exception e
    exit 1
  end

private
  #----------------------------------------------------------------------------
  def _parse_args(argv, flags)
    parser = Args.new()
    flags.each { |f| 
      parser.describe_flag f[:name], f[:help_desc], f[:options] 
    }
    parser.parse argv
  rescue => exc
    @log.exception exc
    Hash.new
  end
end

end
