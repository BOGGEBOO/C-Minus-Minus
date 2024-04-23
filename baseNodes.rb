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
        if lhtemp.is_a?(String) and rhtemp.is_a?(String)
            return eval("'#{lhtemp}'#{@op}'#{rhtemp}'")
        else
            return eval("#{lhtemp}#{@op}#{rhtemp}")
        end
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

class ListNode < Node
    attr_accessor :list, :type

    def initialize(vals, type)
        @vals = vals
        @type = type
        @list = typecheck()
    end

    def typecheck()
        case @type
        when "int"
            checker(CmmInteger)
        when "float"
            checker(CmmFloat)
        when "bool"
            checker(CmmBoolean)
        when "char"
            checker(CmmChar)
        end
        return LinkedList.new(@vals)
    end

    def checker(cmmtype)
        @vals.each do |x|
            if x.is_a?(ExpressionNode)
                if x.evaluate().is_a?(cmmtype)
                    next
                else
                    begin
                        raise(SyntaxError)
                    rescue SyntaxError
                        abort("ERROR: List of wrong type, bitch".red())
                    end
                end
            else
                if x.is_a?(cmmtype)
                    next
                else
                    begin
                        raise(SyntaxError)
                    rescue SyntaxError
                        abort("ERROR: List is of wrong type, bitch".red())
                    end
                end
            end
        end
    end

    def evaluate()
        return @list.print()
    end

end

class ListOpp < Node
    attr_accessor :identifier, :index, :op, :list, :new_val

    def initialize(identifier, index, op, new_val = 0)
        @identifier = identifier
        @index = index
        @op = op
        @new_val = new_val
    end

    def evaluate()
        @list = @identifier.evaluate()
        case @op
        when "index"
            @list.list.at(@index)
        when "append"
            @list.list.append(@index)
        when "pop"
            @list.list.pop()
        when "size"
            @list.list.size()
        when "replace"
            @list.list.replace_at(@index, @new_val)
        end
    end

end


class String
    def red
        "\e[31m#{self}\e[0m"
    end
end
