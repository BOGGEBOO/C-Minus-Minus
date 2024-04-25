# require './baseNodes'
####################################
#       WHILE LOOP                 #
####################################
class WhileLoop < ContainerNode
    attr_accessor :expr, :bumpster

    def initialize(expr, bumpster)
        @expr = expr
        @local_bumpster = bumpster
    end

    def evaluate()
        broken = false
        $scope << {}
        $scope_depth += 1

        $scope[$scope_depth]["42069_looper"] = {"break" => false}
        while @expr.evaluate()
            @local_bumpster.each() do |x|
                if x.is_a?(CmmReturn)
                    return x
                elsif x.is_a?(ContainerNode) and x.will_return().is_a?(CmmReturn)
                    $scope_depth -= 1
                    $scope.pop()
                    return x.evaluate()
                else
                    x.evaluate()
                end
                if $scope[$scope_depth]["42069_looper"]
                    if $scope[$scope_depth]["42069_looper"]["break"]
                        broken = true
                        break
                    end
                end
            end
            if broken
                break
            end
        end
        $scope_depth -=1
        $scope.pop()
    end
end

####################################
#       FOR LOOP                   #
####################################
class ForLoop < ContainerNode
    attr_accessor :var, :expr, :crement, :local_bumpster

    def initialize(var, expr, crement, blocks)
        @var = var
        @expr = expr
        @crement = crement
        @local_bumpster = blocks
    end

    def evaluate()
        broken = false
        $scope << {}
        $scope_depth += 1
        @var.evaluate()

        $scope[$scope_depth]["42069_looper"] = {"break" => false}
        while @expr.evaluate()
            @local_bumpster.each() do |x|
                if x.is_a?(CmmReturn)
                    return x
                elsif x.is_a?(ContainerNode) and x.will_return().is_a?(CmmReturn)
                    $scope_depth -= 1
                    $scope.pop()
                    return x.evaluate()
                else
                    x.evaluate()
                end
                if $scope[$scope_depth]["42069_looper"]
                    if $scope[$scope_depth]["42069_looper"]["break"]
                        broken = true
                        break
                    end
                end
            end
            if broken
                break
            end
        end
        @var.value.value = 0
        $scope_depth -=1
        $scope.pop()

    end
end
####################################
#       CMM BREAK                  #
####################################
class CmmBreak
    def initialize()
    end

    def evaluate()
        index = $scope_depth
        while index >= 0
            if $scope[index]["42069_looper"]
                $scope[index]["42069_looper"]["break"] = true
                break
            else
                index -= 1
            end
        end
    end
end

####################################
#       INCREMENT                  #
####################################
class Increment < Node
    attr_accessor :value

    def initialize(value, inc = CmmInteger.new(1))
        @value = value
        @inc = inc
    end

    def evaluate()
        if @inc.class == LookUp
            @inc = @inc.evaluate()
        end
        if @value.class == LookUp
            ChangeVariable.new(@value.identifier, @value.evaluate().evaluate() + @inc.evaluate()).evaluate()
        else
            @value.value = @value.value + @inc.evaluate()
        end
    end
end

####################################
#       DECREMENT                  #
####################################
class Decrement < Node
    attr_accessor :value

    def initialize(value, dec = CmmInteger.new(1))
        @value = value
        @dec = dec
    end

    def evaluate()
        if @dec.class == LookUp
            @dec = @dec.evaluate()
        end
        if @value.class == LookUp
            ChangeVariable.new(@value.identifier, @value.evaluate.evaluate - @dec.evaluate()).evaluate()
        else
            @value.value = @value.value - @dec.evaluate()
        end
    end
end


class Multiment < Node
    attr_accessor :value

    def initialize(value, dec = CmmInteger.new(1))
        @value = value
        @dec = dec
    end

    def evaluate()
        if @dec.class == LookUp
            @dec = @dec.evaluate()
        end
        if @value.class == LookUp
            ChangeVariable.new(@value.identifier, @value.evaluate.evaluate * @dec.evaluate()).evaluate()
        else
            @value.value = @value.value * @dec.evaluate()
        end
    end
end


class Diviment < Node
    attr_accessor :value

    def initialize(value, dec = CmmInteger.new(1))
        @value = value
        @dec = dec
    end

    def evaluate()
        if @dec.class == LookUp
            @dec = @dec.evaluate()
        end
        if @value.class == LookUp
            ChangeVariable.new(@value.identifier, @value.evaluate.evaluate / @dec.evaluate()).evaluate()
        else
            @value.value = @value.value / @dec.evaluate()
        end
    end
end


class Potensiment < Node
    attr_accessor :value

    def initialize(value, dec = CmmInteger.new(1))
        @value = value
        @dec = dec
    end

    def evaluate()
        if @dec.class == LookUp
            @dec = @dec.evaluate()
        end
        if @value.class == LookUp
            ChangeVariable.new(@value.identifier, @value.evaluate.evaluate ** @dec.evaluate()).evaluate()
        else
            @value.value = @value.value ** @dec.evaluate()
        end
    end
end
