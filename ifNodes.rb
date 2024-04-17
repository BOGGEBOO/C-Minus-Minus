# require './baseNodes'
####################################
#   IF STATEMENT                   #
####################################
class IfStatement < Node
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
