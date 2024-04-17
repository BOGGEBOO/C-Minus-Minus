# require './baseNodes'
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
        broken = false
        $scope << {}
        $scope_depth +=1
        $scope[$scope_depth]["42069_looper"] = {"break" => false}
        while @expr.evaluate()
            @local_bumpster.each() do |x|
                x.evaluate()
                if $scope[$scope_depth]["42069_looper"]["break"]
                    broken = true
                    break
                # else
                #     x.evaluate()
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
class ForLoop < Node
    attr_accessor :var, :expr, :creme, :blocks

    def initialize(var, expr, creme, blocks)
        @var = var
        @expr = expr
        @creme = creme
        @blocks = blocks
    end

    def evaluate()
        $scope << {}
        $scope_depth +=1
        @var.evaluate()
        @blocks << @creme
        loopObj = WhileLoop.new(@expr, @blocks)
        loopObj.evaluate()
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
        if @value.class == LookUp
            ChangeVariable.new(@value.identifier, @value.evaluate.evaluate + @inc.evaluate()).evaluate()
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
        if @value.class == LookUp
            ChangeVariable.new(@value.identifier, @value.evaluate.evaluate - @dec.evaluate()).evaluate()
        else
            @value.value = @value.value - @dec.evaluate()
        end
    end
end
