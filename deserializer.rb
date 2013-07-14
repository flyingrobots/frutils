__dir__ = File.expand_path '..', __FILE__
require File.join __dir__, 'serialization.rb'

require File.join __dir__, 'serializer.rb'

module FlyingRobots

  #############################################################################
  class Deserializer
  public    
    #--------------------------------------------------------------------------
    def deserialize(hash, object = nil)
      deserialize_value hash, object
    end


  private
    #--------------------------------------------------------------------------
    def create_object_of_type(type)
      raise "Unspecified type" if type.nil?
      proto = nil
      type.each { |t|
        if proto.nil?
          proto = Object.const_get t
        else
          proto = proto.const_get t
        end
      }
      object = proto.new
    end


    #--------------------------------------------------------------------------
    def deserialize_ivars(hash, object)
      hash.each { |key, value|
        next if key == Serialization.type_key
        # error when key isn't an ivar
        name = "@#{key}"
        if not object.instance_variable_defined? name
          raise "Unknown field '#{name}' when deserializing '#{object.class}'"
        end
        # deserialize value
        object.instance_variable_set name, deserialize_value(value)
      }
      object
    end

    #--------------------------------------------------------------------------
    def deserialize_hash(hash)
      h = {}
      hash.each { |key, value|
        h[key] = deserialize_value value
      }
      h
    end

    
    #--------------------------------------------------------------------------
    def deserialize_array(array)
      a = []
      array.each { |element|
        a.push deserialize_value element
      }
      a
    end


    #--------------------------------------------------------------------------
    def deserialize_time(time)
      Time.parse(time['value'])
    end


    #--------------------------------------------------------------------------
    def determine_type(data, object)
      if object
        return object.class
      elsif data.class == Hash and data.key? Serialization.type_key
        type = nil
        data[Serialization.type_key].each { |t|
          if type.nil?
            type = Object.const_get t
          else
            type = type.const_get t
          end
        }
      else
        data.class
      end
    end


    #--------------------------------------------------------------------------
    def deserialize_value(value, object = nil)
      type = determine_type value, object
      if Serialization::basic_objects.include? type
        value
      elsif type == Time or type == Time.to_s
        deserialize_time value
      elsif type == Hash
        deserialize_hash value
      elsif type == Array
        deserialize_array value
      else
        object ||= create_object_of_type type
        deserialize_ivars value, object
      end
    end


  end

end

