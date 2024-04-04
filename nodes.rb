class AritmheticExpression
    attr_reader :lhs, :op, :rhs
    def initialize(lhs, op, rhs)
        @lhs = lhs
        @op = op
        @rhs = rhs
    end

    def evaluate()
        return eval("#{@lhs.evaluate}#{@op}#{@rhs.evaluate}")
    end
end

class CmmFloat

    attr_accessor :value

    def initialize(val)
        @value = val
    end

    def evaluate()
        return @value
    end

    #def round()
    #end
end

class CmmInteger

    attr_accessor :value

    def initialize(val)
        @value = val
    end

    def evaluate()
        return @value
    end

end

class BinaryExpression
    attr_reader :lhs, :op, :rhs

    def initialize(lhs, op, rhs)
        @lhs = lhs
        @op = op
        @rhs = rhs
    end

    def evaluate()
        return eval("#{lhs.evaluate}#{op}#{rhs.evaluate}")
    end

end

class CmmBoolean
    attr_accessor :value

    def initialize(val)
        @value = val
    end

    def evaluate()
        return @value
    end

end


# a = CmmInteger.new(7)
# b = CmmInteger.new(3)
# c = CmmFloat.new(5.5)

# sum = AritmheticExpression.new(a, "+", b)

# res = AritmheticExpression.new(sum, "/", c)

# a = CmmBoolean.new(true)
# b = CmmBoolean.new(false)

# res = BinaryExpression.new(a, "!=", b)

# puts res.evaluate()
