class Node
    def evaluate()
    end
end

class AritmheticExpression < Node
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

class CmmFloat < Node

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

class CmmInteger < Node

    attr_accessor :value

    def initialize(val)
        @value = val
    end

    def evaluate()
        return @value
    end

end

class BinaryExpression < Node
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

class CmmBoolean < Node
    attr_accessor :value

    def initialize(val)
        @value = val
    end

    def evaluate()
        return @value
    end

end

class CmmFunction < Node
    attr_accessor :type, :name, :params, :codeBlock

    def initialize(type, name, params, codeBlock)
        @type = type
        @name = name
        @codeBlock = codeBlock
    end

    def evaluate()
        self.codeBlock.evaluate()
    end
end

class CodeBlock < Node
    attr_accessor :params
    def initialize(params)
        @params = params
    end

    def evaluate()

    end
end


class Print < Node
    attr_accessor :val

    def initialize(val)
        @val = val
        evaluate
    end

    def evaluate()
        puts "********************************"
        puts val
    end
end
