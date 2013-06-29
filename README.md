# frutils
Some junk code I reuse in various ruby projects.

* `FlyingRobots::Application` does a bunch of application-related boilerplate nonsense, like parse command line arguments, print help messages, etc.
* `FlyingRobots::Args` is a simple command line arguments parser
* `FlyingRobots::Log` is a simple logger

## FlyingRobots::Application

Hello world example:

    FlyingRobots::Application.new(ARGV).run { |opts|
        puts "hello world"
    }

`FlyingRobots::Application` works like this:

1. You create a configuration hash, within which you define the command line options you wanna parse
2. You create a new `FlyingRobots::Application` object and initialize it with ARGV and the config hash
3. It parses ARGV, handling unrecognized and malformed arguments for you by printing a help message
4. Passes the parsed arguments to your block when you call `run`

Simple as that!

## FlyingRobots::Args

If you use `FlyingRobots::Application`, above, you won't need to directly use `Args`, but it's still good to know how to describe flags for `Args` to parse. Each flag must be defined in a hash containing the following keys:

* `:name` [required] The option's name (displayed in the help message)
* `:short` [optional] The short form of the flag, such as 'f' for '-f', or 'e' for '-e'
* `:long` [optional] The long form of the flag, such as 'file' for '--file', or 'example' for '--example'
* `:description` [required] The help text to describe the option
* `:default` [optional] Default value
* `:type` [optional] Specifies the type. See `FlyingRobots::Types` in `arg_types.rb` for more information (boolean by default)
* `:multi` [optional] True if multiple values are allowed (false by default)
* `:required` [optional] True if this flag must appear in the command line arguments (false by default)

For example:

    flag_desc = {
        :name => "magic",
        :description => "Enables magic.",
        :required => true
    }

## FlyingRobots::Log

A simple volume-based logger. Pretty prints arrays, hashes, and exceptions. Available volumes:

* `VOLUME_TRACE` Used to log spammy things
* `VOLUME_DEBUG` Used to log debug info
* `VOLUME_INFO` Used to log informative messages
* `VOLUME_WARN` Used to log warnings
* `VOLUME_ERROR` Used to log errors
* `VOLUME_MUTE` Used to suppress all messages

When you create a new `Log`, you configure its volume. Messages printed with a volume below the log's configured level won't appear. Errors and warnings will be printed to stderr and everything else goes to stdout.
