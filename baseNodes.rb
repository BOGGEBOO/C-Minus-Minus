#!/usr/bin/env ruby

$scope = [{}]
$scope_depth = 0

$funcs = {}

####################################
#     NODE (BASECLASS)             #
####################################
class Node
    def evaluate()
    end
end

####################################
#    EXPRESSION NODE               #
####################################
class ExpressionNode < Node
    def evaluate()
    end
end

####################################
#   ARITHMETIC EXPRESSION          #
####################################
class AritmheticExpression < ExpressionNode
    attr_reader :lhs, :op, :rhs
    def initialize(lhs, op, rhs)
        @lhs = lhs
        @op = op
        @rhs = rhs
    end

    def evaluate()
        lhtemp = @lhs
        while lhtemp.is_a?(Node)
            lhtemp = lhtemp.evaluate()
        end
        rhtemp = @rhs
        while rhtemp.is_a?(Node)
            rhtemp = rhtemp.evaluate()
        end
        result = eval("#{lhtemp}#{@op}#{rhtemp}")
        if result.is_a?(Integer)
            return CmmInteger.new(result)
        elsif result.is_a?(Float)
            return CmmFloat.new(result)
        end
    end
end


####################################
#   CMM FLOAT                      #
####################################
class CmmFloat < Node

    attr_accessor :value

    def initialize(val)
        @value = val
    end

    def evaluate()
        return @value
    end
end

####################################
#   CMM INTEGER                    #
####################################
class CmmInteger < Node

    attr_accessor :value

    def initialize(val)
        @value = val
    end

    def evaluate()
        return @value
    end

end

####################################
#   CMM Char                    #
####################################
class CmmChar < Node

    attr_accessor :value

    def initialize(val)
        @value = val
    end

    def evaluate()
        return @value
    end

end

####################################
#   BINARY EXPRESSION              #
####################################
class BinaryExpression < ExpressionNode
    attr_reader :lhs, :op, :rhs

    def initialize(lhs, op, rhs)
        @lhs = lhs
        @op = op
        @rhs = rhs
    end

    def evaluate()
        lhtemp = @lhs
        while lhtemp.is_a?(Node)
            lhtemp = lhtemp.evaluate()
        end
        rhtemp = @rhs
        while rhtemp.is_a?(Node)
            rhtemp = rhtemp.evaluate()
        end
        return eval("#{lhtemp}#{@op}#{rhtemp}")
    end
end

####################################
#      UNARY EXPRESSION            #
####################################
class UnaryExpression < ExpressionNode
    attr_accessor :expr

    def initialize(value)
        @expr = value
    end

    def evaluate()
        return @expr.evaluate()
    end
end

####################################
#   CMM BOOLEAN                    #
####################################
class CmmBoolean < Node
    attr_accessor :value

    def initialize(val)
        @value = val
    end

    def evaluate()
        return @value
    end

end


####################################
#   PRINT                          #
####################################
class Print < Node
    attr_accessor :val

    def initialize(val)
        @val = val
    end

    def evaluate()
        #loop för att gå ner genom alla noder
        temp = @val
        while temp.is_a?(Node)
            temp = temp.evaluate()
        end
        # puts "\n\n********************************"
        puts temp
        return temp
        # puts "********************************"
    end
end


class String
    def red
    "\e[31m#{self}\e[0m"
    end
end
