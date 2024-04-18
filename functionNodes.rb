
####################################
#   CMM FUNCTION                   #
####################################
class CmmFunction < Node
    attr_accessor :type, :params, :codeBlock

    def initialize(type, params, codeBlock)
        @type = type
        @params = params
        @codeBlock = codeBlock
    end

    def evaluate(values)
        $scope << {}
        $scope_depth +=1
        replacePossible = false

        #p values[0].evaluate
        values.each_with_index do |value,index|
            if @params[index][@params[0].keys()[index]] == "int" && values[index].class == CmmInteger
                replacePossible = true
            elsif @params[index][@params[0].keys()[index]] == "int" && values[index].evaluate.class == CmmInteger
                value = values[index].evaluate
                replacePossible = true
            elsif @params[index][@params[0].keys()[index]] == "float" && values[index].class == CmmFloat
                replacePossible = true
            elsif @params[index][@params[0].keys()[index]] == "float" && values[index].evaluate.class == CmmFloat
                value = values[index].evaluate
                replacePossible = true
            elsif @params[index][@params[0].keys()[index]] == "bool" && values[index].class == CmmBoolean
                replacePossible = true
            elsif @params[index][@params[0].keys()[index]] == "bool" && values[index].evaluate.class == CmmBoolean
                value = values[index].evaluate
                replacePossible = true
            end
            if replacePossible
                $scope[$scope_depth][@params[index].keys()[0]] = value
            else
                begin
                    raise(SyntaxError)
                rescue SyntaxError
                    abort("ERROR: faulty parameter, you dumb fuck".red())
                end
            end
        end
        ret = 0
        @codeBlock.each do |x|
            if x.evaluate.is_a?(CmmReturn)
                return x.evaluate()
            elsif x.is_a?(CmmReturn)
                return x.evaluate()
            else
                x.evaluate
            end
        end

        $scope_depth -=1
        $scope.pop()
    end
end

####################################
#   CMM RETURN                     #
####################################
class CmmReturn < Node
    attr_accessor :thing, :type

    def initialize(thing)
        @thing = thing
        @type = nil
    end

    def evaluate()

        #p @thing
        if @thing.is_a?(LookUp) or @thing.is_a?(ExpressionNode)
            @thing = @thing.evaluate
            if @thing == true
                @thing = CmmBoolean.new(true)
            elsif @thing == false
                @thing = CmmBoolean.new(false)
            end
        end
        #p @thing
        case @thing
        when CmmInteger
            check = "int"
        when CmmFloat
            check = "float"
        when CmmBoolean
            check = "bool"
        when FunctionCall
            # p @thing.gettype()
            # p @type
            check = @thing.gettype()
        else
            # p @thing
            # p @type
            begin
                raise(SyntaxError)
            rescue SyntaxError
                abort("ERROR: incorrect return type, you dumb fuck".red())
            end
        end
        # puts "**********"
        # p @type
        # p check
        if check == @type
            #p @thing
            if @thing.is_a?(FunctionCall)
                @thing.evaluate()
            else
                return @thing
            end
        end
    end

end

####################################
#   CMM FUNCTION CALL              #
####################################
class FunctionCall < Node
    attr_accessor :name, :params

    def initialize(name, params)
        @name = name
        @params = params
    end

    def gettype()
        return $funcs[@name].type
    end

    def evaluate()
        # p "WWWWWW"
        $funcs[@name].codeBlock.each do |x|
            if x.is_a?(ContainerNode)
                x.has_return.each do |c|
                    if c.type == nil
                        c.type = gettype()
                    end
                end
                if x.is_a?(ElifStatment)
                    x.returns = []
                end
            elsif x.is_a?(CmmReturn)
                if x.type == nil
                    x.type = gettype()
                end
            end
        end
        $funcs[@name].evaluate(@params)
    end
end

####################################
#   CMM FUNCTION DECLARATION       #
####################################
class FunctionDeclaration < Node
    attr_accessor :identifier, :function

    def initialize(identifier, func)
        @identifier = identifier
        @function = func
    end

    def evaluate()
        $funcs[@identifier] = @function
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
        #p @statements
        @statements.each do |x|
            x.evaluate()
        end
        #! se variabellista
        #p $scope
    end
end
