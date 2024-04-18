# require './baseNodes'

class ContainerNode < Node
    def initialize()
    end

    def has_return()
        @local_bumpster.each() do |x|
            if x.is_a?(CmmReturn)
                return [x]
            end
        end
    end

end

####################################
#   IF STATEMENT                   #
####################################
class IfStatement < ContainerNode
    attr_accessor :expr, :local_bumpster
    def initialize(a,b)
        @expr = a
        @local_bumpster = b
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
class ElifStatment < ContainerNode
    attr_accessor :expr, :local_bumpster, :next_elif, :returns

    def initialize(expr, bumpster, elif = nil)
        @expr = expr
        @local_bumpster = bumpster
        @next_elif = elif
        @@returns = []
    end

    def has_return()
        found = false
        @local_bumpster.each() do |x|
            if x.is_a?(CmmReturn)
                @@returns << x
            end
        end
        if @next_elif != nil
            if @next_elif.is_a?(ElseStatment)
                @@returns.concat(@next_elif.has_return())
            else
                @next_elif.has_return()
            end
        end
        return @@returns
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
class ElseStatment < ContainerNode
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
