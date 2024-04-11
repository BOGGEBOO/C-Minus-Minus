#!/usr/bin/env ruby

$scope = [{}]
$scope_depth = 0

####################################
#            NODE                  #
####################################
class Node
    def evaluate()
    end
end

####################################
#   ARITHMETIC EXPRESSION          #
####################################
class AritmheticExpression < Node
    attr_reader :lhs, :op, :rhs
    def initialize(lhs, op, rhs)
        @lhs = lhs
        @op = op
        @rhs = rhs
        # p @lhs
    end

    def evaluate()
        lhtemp = @lhs
        while lhtemp.is_a?(Node)
            # p lhtemp
            lhtemp = lhtemp.evaluate()
            # p lhtemp
        end
        rhtemp = @rhs
        while rhtemp.is_a?(Node)
            rhtemp = rhtemp.evaluate()
        end
        # p rhtemp
        result = eval("#{lhtemp}#{@op}#{rhtemp}")
        if result.is_a?(Integer)
            # p CmmInteger.new(result)
            return CmmInteger.new(result)
        elsif result.is_a?(Float)
            return CmmFloat.new(result)
        end
        # case result.class
        # when Integer

        # when Float

        # end
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
#   BINARY EXPRESSION              #
####################################
class BinaryExpression < Node
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
#   CMM FUNCTION                   #
####################################
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

####################################
#   ASSIGNMENT                     #
####################################
class Assignment < Node
    attr_accessor :identifier, :value, :type

    def initialize(identifier, val, type)
        @identifier = identifier
        @value = val
        @type = type
    end

    def evaluate()
        case @type
        when "int"
            if @value.is_a?(AritmheticExpression)
                #p @value
                $scope[$scope_depth][@identifier] = @value
            else
                $scope[$scope_depth][@identifier] = @value
            end
        when "float"
            $scope[$scope_depth][@identifier] = @value
        when "bool"
            # cant send false from :value
            if @value == "True"
                temp = true
            elsif @value == "False"
                temp = false
            end
            $scope[$scope_depth][@identifier] = CmmBoolean.new(@value)
        end
    end
end

####################################
#   MAIN FUNCTION                  #
####################################
class MainFunction < Node
    attr_accessor :statements

    def initialize(statements)
        @statements = statements
    end

    def evaluate()
        @statements.each do |x|
            x.evaluate()
        end
        #! se variabellista
        #p $scope
    end
end

####################################
#   LOOK UP                        #
####################################
class LookUp < Node

    attr_accessor :identifier

    def initialize(identifier)
        @identifier = identifier
    end

    def evaluate()
        index = $scope_depth
        while index >= 0
            if $scope[index][@identifier]
                temp = $scope[index][@identifier]
                break
            else
                index -= 1
            end
        end
        if temp.nil?
            begin
                raise(SyntaxError)
            rescue SyntaxError
                abort("ERROR: The variable '#{@identifier}' does not exist, you dumb fuck".red)
            end
        end
        while true
            if temp.class == CmmInteger || temp.class == CmmFloat
                break
            elsif temp.evaluate.class != CmmInteger || temp.evaluate.class != CmmFloat
                temp = temp.evaluate
            end
        end

        return temp
    end
end

####################################
#   CHANGE VARIABLE                #
####################################
class ChangeVariable < Node
    attr_accessor :var, :value

    def initialize(var, value)
        @var = var
        @value = value
    end

    def evaluate()
        index = $scope_depth
        while index >= 0
            if $scope[index][@var]
                if $scope[index][@var].value.class == @value.class
                    $scope[index][@var].value = @value
                else
                    $scope[index][@var].value = @value.evaluate()
                end
                break
            else
                index -= 1
            end
        end

    end

end

####################################
#   IF STATEMENT                   #
####################################
class IfStatement < Node
    attr_accessor :expr, :local_bumpster, :dupster
    def initialize(a,b,dupster)
        @expr = a
        @local_bumpster = b
        @dupster = dupster
    end

    def evaluate()
        $scope << {}
        $scope_depth += 1
        if @expr.evaluate()
            @local_bumpster.each() do |x|
                x.evaluate()
            end
        end
        $scope_depth -=1
        $scope.pop()
    end
end

####################################
#   ELSE IF STATEMENT              #
####################################
class ElifStatment < Node
    attr_accessor :expr, :local_bumpster, :next_elif

    def initialize(expr, bumpster, elif = nil)
        @expr = expr
        @local_bumpster = bumpster
        @next_elif = elif
    end

    def evaluate()
        $scope << {}
        $scope_depth +=1
        if @expr.evaluate()
            @local_bumpster.each() do |x|
                x.evaluate()
            end
        elsif @next_elif != nil
            @next_elif.evaluate()
        end
        $scope_depth -=1
        $scope.pop()
    end

end

####################################
#   ELSE STATEMENT                 #
####################################
class ElseStatment < Node
    attr_accessor :bumpster

    def initialize(bumpster)
        @local_bumpster = bumpster
    end

    def evaluate()
        $scope << {}
        $scope_depth +=1
        @local_bumpster.each() do |x|
            x.evaluate()
        end
        $scope_depth -=1
        $scope.pop()
    end
end

####################################
#       WHILE LOOP                 #
####################################
class WhileLoop < Node
    attr_accessor :expr, :bumpster

    def initialize(expr, bumpster)
        @expr = expr
        @local_bumpster = bumpster
    end

    def evaluate()
        $scope << {}
        $scope_depth +=1
        while @expr.evaluate()
            @local_bumpster.each() do |x|
                x.evaluate()
            end
        end
        $scope_depth -=1
        $scope.pop()
    end
end

####################################
#       INCREMENT                  #
####################################
class Increment < Node
    attr_accessor :value

    def initialize(value)
        @value = value
    end

    def evaluate()
        if @value.class == LookUp
            ChangeVariable.new(@value.identifier, @value.evaluate.evaluate + 1).evaluate()
        else
            @value.value = @value.value + 1
        end
    end
end

####################################
#       DECREMENT                  #
####################################
class Decrement < Node
    attr_accessor :value

    def initialize(value)
        @value = value
    end

    def evaluate()
        if @value.class == LookUp
            ChangeVariable.new(@value.identifier, @value.evaluate.evaluate - 1).evaluate()
        else
            @value.value = @value.value - 1
        end
    end
end


class String
    def red
    "\e[31m#{self}\e[0m"
    end
end
