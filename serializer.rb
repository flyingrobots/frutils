__dir__ = File.expand_path '..', __FILE__
require File.join __dir__, 'serialization.rb'

module FlyingRobots

  #############################################################################
  class Serializer
  public
    #--------------------------------------------------------------------------
    def initialize(options = {})
      @symbolicate_keys = options[:symbolicate_keys] == true
    end


    #--------------------------------------------------------------------------
    def serialize(object)
      if object.class == Hash
        serialize_hash object
      elsif object.class == Array
        serialize_array object
      elsif object.class == Time
        serialize_time object
      else
        serialize_object object
      end
    end


    #--------------------------------------------------------------------------
    def to_json(object)
      h = serialize object
      JSON.generate h
    end


    #--------------------------------------------------------------------------
    def to_pretty_json(object)
      h = serialize object
      JSON.pretty_generate h
    end

  private
    #--------------------------------------------------------------------------
    def serialize_object(object)
      # serialize class information
      h = { Serialization.type_key => object.class.to_s.split('::') }
      # serialize ivars
      ivars = object.instance_variables
      if object.respond_to? :serializer_ignore
        ignore = object.serializer_ignore
        ivars = object.instance_variables.select { |ivar| 
          not ignore.include? ivar
        }
      end
      ivars.each { |ivar|
        value = object.instance_variable_get ivar
        serialize_and_store_with_key h, ivar, value
      }
      h
    end


    #--------------------------------------------------------------------------
    def serialize_hash(hash)
      h = {}
      hash.each { |key, value|
        serialize_and_store_with_key h, key, value
      }
      h
    end


    #--------------------------------------------------------------------------
    def serialize_array(array)
      a = []
      array.each { |object|
        if Serialization::basic_objects.include? object.class
          a.push object
        else
          a.push serialize_object object
        end
      }
      a
    end


    #--------------------------------------------------------------------------
    def serialize_time(time)
      { 
        Serialization.type_key => Time, 
        'value' => time.to_s
      }
    end


    #--------------------------------------------------------------------------
    def serialize_and_store_with_key(h, key, value)
      key = key[1..-1] if key.chars.first == '@'
      key = key.to_sym if @symbolicate_keys
      if Serialization::basic_objects.include? value.class
        h[key] = value
      else
        h[key] = serialize value
      end
      h
    end

        
  end


end

