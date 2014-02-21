require 'set'
module Qrb
  #
  # A union type (aka algebraic type) allows capturing information types
  # through generalization/disjunction. For instance,
  #
  #     Number = Int|Real
  #
  # This class allows capturing such union types, as follows:
  #
  #     Int    = BuiltinType.new(Fixnum)
  #     Real   = BuiltinType.new(Float)
  #     Number = UnionType.new([ Int, Real ])
  #
  # When transforming a value through `up`, the different candidate types are
  # tried in specified order. The first one that succeeds at building the
  # value ends the process and the value is simply returned. Accordingly,
  # the concrete representation will be
  #
  #     R(Number) = R(Int) ^ R(Real) = Fixnum ^ Float = Numeric
  #
  # where `^` denotes the `least common super type` operator on ruby classes.
  #
  # Accordingly, the `up` transformation function has the following signature:
  #
  #     up :: Alpha  -> Number  throws TypeError
  #     up :: Object -> Numeric throws UpError
  #
  class UnionType < Type

    def initialize(candidates, name = nil)
      unless candidates.all?{|c| c.is_a?(Type) }
        raise ArgumentError, "[Qrb::Type] expected, got #{candidates}"
      end

      super(name)
      @candidates = candidates.freeze
    end
    attr_reader :candidates

    # Invoke `up` on each candidate type in turn. Return the value returned by
    # the first one that does not fail. Fail with an UpError if no candidate
    # succeeds at tranforming `value`.
    def up(value, handler = UpHandler.new)

      # Do nothing on UpError as the next candidate could be the good one!
      candidates.each do |c|
        success, uped = handler.just_try do
          c.up(value, handler)
        end
        return uped if success
      end

      # No one succeed, just fail
      handler.failed!(self, value)
    end

    def default_name
      candidates.map(&:name).join('|')
    end

    def ==(other)
      return false unless other.is_a?(UnionType)
      set_equal?(candidates, other.candidates)
    end
    alias :eql? :==

    def hash
      self.class.hash ^ set_hash(self.candidates)
    end

  end # class UnionType
end # module Qrb
