#!/usr/bin/env ruby

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
    attr_accessor :blocks, :block

    def initialize(blocks, block)
        @blocks = blocks
        @block = block
        @result = []
    end

    def evaluate()
        @result << @blocks.evaluate
        @result << @block.evaluate

        # @blocks.each do |x|
        #     @result << x.evaluate
        # end
        return @result
    end
end


class Print < Node
    attr_accessor :val

    def initialize(val)
        @val = val
        # evaluate
    end

    def evaluate()
        #loop för att gå ner genom alla noder
        while @val.is_a?(Node)
            @val = @val.evaluate()
        end
        # puts "\n\n********************************"
        puts @val
        return @val
        # puts "********************************"
    end
end


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
            CMM.setVar(@identifier, CmmInteger.new(@value))
        when "float"
            CMM.setVar(@identifier, CmmFloat.new(@value))
        when "bool"
            # cant send false from :value
            if @value == "True"
                temp = true
            elsif @value == "False"
                temp = false
            end
            CMM.setVar(@identifier, CmmBoolean.new(temp))
        end
    end
end


class MainFunction < Node
    attr_accessor :statements

    def initialize(statements)
        @statements = statements
    end

    def evaluate()
        @statements.each do |x|
            x.evaluate()
        end
    end
end


class LookUp < Node

    attr_accessor :identifier

    def initialize(identifier)
        @identifier = identifier
    end

    def evaluate()
        temp = CMM.vars(@identifier).evaluate
        if !temp.is_a?(CmmInteger) || !temp.is_a?(CmmFloat) || !temp.is_a?(CmmBoolean)
            temp = temp.evaluate
        end
    end
end


# !!! FIXA DEN HÄR SKITEN !!!
#scopehanteringsbullshitfanhelvetesjävlaskit

class IfStatement < Node
    attr_accessor :expr, :local_bumpster, :dupster
    def initialize(a,b,dupster)
        @expr = a
        @local_bumpster = b
        @dupster = dupster
    end

    def evaluate()
        if @expr.evaluate()
            @local_bumpster.each() do |x|
                x.evaluate()
            end
        end
    end
end
