
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
                replacePossible = true
            elsif @params[index][@params[0].keys()[index]] == "float" && values[index].class == CmmFloat
                replacePossible = true
            elsif @params[index][@params[0].keys()[index]] == "float" && values[index].evaluate.class == CmmFloat
                replacePossible = true
            elsif @params[index][@params[0].keys()[index]] == "bool" && values[index].class == CmmBoolean
                replacePossible = true
            elsif @params[index][@params[0].keys()[index]] == "bool" && values[index].evaluate.class == CmmBoolean
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
        @codeBlock.each do |x|
            if x.is_a?(CmmReturn)

                return x.evaluate(@type)
                break
            end
            x.evaluate()
        end
        $scope_depth -=1
        $scope.pop()
    end
end

####################################
#   CMM RETURN                     #
####################################
class CmmReturn < Node
    attr_accessor :thing

    def initialize(thing)
        @thing = thing
    end

    def evaluate(type)
        # p @thing
        if @thing.is_a?(LookUp) or @thing.is_a?(ExpressionNode)
            @thing = @thing.evaluate
            if @thing == true
                @thing = CmmBoolean.new(true)
            elsif @thing == false
                @thing = CmmBoolean.new(false)
            end
        end
        # p @thing
        case @thing
        when CmmInteger
            check = "int"
            # puts "INT"
        when CmmFloat
            check = "float"
            # puts "FLOAT"
        when CmmBoolean
            check = "bool"
            # puts "NAAAH"
        else
            begin
                raise(SyntaxError)
            rescue SyntaxError
                abort("ERROR: incorrect return type, you dumb fuck".red())
            end
        end
        if check == type
            return @thing
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
