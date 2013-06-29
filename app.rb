file_dir = File.expand_path File.dirname(__FILE__)
require File.join file_dir, 'args.rb'
require File.join file_dir, 'log.rb'

module FlyingRobots

class Application
public
  #----------------------------------------------------------------------------
  def intiailize(argv, flags)
    puts "hi"
    @log = Log.new({
      :name => "App",
      :volume => Log::VOLUME_DEBUG
    })
    @options = parse_args(argv, flags)
    @log.debug @options
  end

  #----------------------------------------------------------------------------
  def run(&block)
    @log.debug "run"
    yield @options
    @log.debug "run done"
    rescue => e
    @log.exception e
    exit 1
  end

private
  #----------------------------------------------------------------------------
  def parse_args(argv, flags)
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
