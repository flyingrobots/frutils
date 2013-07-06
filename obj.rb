module FlyingRobots
   
class Obj
  #--------------------------------------------------------------------------
  def self.to_hash(object, options = {})
    object.instance_variables.inject({}) { |h, ivar|
      key = (options[:symbolic_keys] == true) ? ivar[1..-1].to_sym : ivar[1..-1].to_s
      h[key] = object.instance_variable_get(ivar)
      h
    }
  end

end

end

