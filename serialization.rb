module FlyingRobots

  #############################################################################
  class Serialization
    #--------------------------------------------------------------------------
    @@basic_objects =
    [
      Bignum,
      FalseClass,
      Fixnum,
      Float,
      Integer,
      String,
      TrueClass,
      NilClass
    ]


    #--------------------------------------------------------------------------
    def self.basic_objects
      @@basic_objects
    end


    #--------------------------------------------------------------------------
    def self.type_key
      '^t'
    end


  end


end

