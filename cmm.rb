#!/usr/bin/env ruby
require './rdparse'
require './nodes'


class CMM

    def initialize()

        @cmmParser = Parser.new("CMM") do
            token(/\s+/)
            token(/\d+\.\d+/) { |x| x.to_f }
            token(/\d+/) { |x| x.to_i }
            token(/\w+/) { |x| x }
            token(/;/) { |x| x }
            token(/True/) { |x| x }
            token(/False/) { |x| x }

            # Längst ner yo
            token(/./) { |x| x }


            start :program do
                match(:func_declares) do |x|
                    x.each do |c|
                        c.evaluate()
                    end
                # x.statements.each_with_index do |val, index|
                    #     print "\n#{index + 1}. "; p val
                    # end
                    # puts "\n\n\n"
                end
            end


            rule :func_declares do
                match(:func_declares, :func_declare) do |x,c|
                    x << c
                    x
                end
                match(:func_declare) { |x| [x] }
            end

            rule :func_declare do
                match(:main) { |x| MainFunction.new(x)}
                match(:new_function) {|x| x }
            end

            rule :main do
                match(:type, /codeGoBr[r]+/, '(', ')', '{', '}') { 0 }
                match(:type, /codeGoBr[r]+/, '(', ')', '{', :code_blocks, '}') { |_, _, _, _, _, x, _| x }
            end

            rule :new_function do
                match(:type, :identifier, '(', :params, ')', '{', :code_blocks, '}') do |type,identifier,_,params,_,_,blocks,_|
                    FunctionDeclaration.new(identifier, CmmFunction.new(type, params, blocks))
                end
            end

            rule :code_blocks do
                match(:code_blocks, :code_block) do |x, c|
                    if c.class == Array
                        x.concat(c)
                    else
                        x << c
                    end
                    x
                end
                match(:code_block) { |x| [x] }
            end

            rule :code_block do
                match(:assign)
                match(:print)
                match(:if_statement)
                match(:change_var)
                match(:while_loop)
                match(:increment)
                match(:decrement)
                match(:call_function)
            end

            rule :call_function do
                match(:identifier, '(', :values, ')', ';') do |name,_,params,_,_|
                    FunctionCall.new(name, params)
                end
            end

            rule :assign do
                match(:type, :identifier, '=', :value, ';') do |type, identifier, _, value, _|
                    Assignment.new(identifier, value, type)
                end
            end

            rule :change_var do
                match(:identifier, '=', :value, ';') do |identifier, _, new_value, _|
                    ChangeVariable.new(identifier, new_value)
                end
            end

            rule :if_statement do
                match('if', '(', :if_expr, ')', '{', :code_blocks, '}', :else_statement) do |_,_,a,_,_,b,_,c|
                    ElifStatment.new(a,b,c)
                end
                match('if', '(', :if_expr, ')', '{', :code_blocks, '}', :elif_statements) do |_,_,a,_,_,b,_,c|
                    ElifStatment.new(a,b,c)
                end
                match('if', '(', :if_expr, ')', '{', :code_blocks, '}') do |_,_,a,_,_,b,_|
                    IfStatement.new(a, b)
                end

            end

            rule :if_expr do
                match(:value, :operator, :value) do |val1, op, val2|
                    BinaryExpression.new(val1, op, val2)
                end
                match(:boolean) do |bool|
                    UnaryExpression.new(bool)
                end
            end

            rule :else_statement do
                match('else', '{', :code_blocks, '}') do |_,_,a,_|
                    ElseStatment.new(a)
                end
            end

            rule :elif_statements do
                match(:elif_statements, :elif_statement) do |a,b|
                    a.next_elif = b
                end
                match(:elif_statement) do |a|
                    a
                end

            end

            rule :elif_statement do
                match('elif', '(', :if_expr, ')', '{', :code_blocks, '}', :elif_statement) do |_,_,a,_,_,b,_,c|
                    ElifStatment.new(a,b,c)
                end
                match('elif', '(', :if_expr, ')', '{', :code_blocks, '}', :else_statement) do |_,_,a,_,_,b,_,c|
                    ElifStatment.new(a,b,c)
                end
                match('elif', '(', :if_expr, ')', '{', :code_blocks, '}') do |_,_,a,_,_,b,_|
                    ElifStatment.new(a,b)
                end

            end

            rule :while_loop do
                match('while', '(', :if_expr, ')', '{', :code_blocks, '}') do |_,_,a,_,_,b,_|
                    WhileLoop.new(a,b)
                end
            end

            rule :increment do
                match(:value, '+', '+', ';') do |a,_,_,_|
                    Increment.new(a)
                end
            end

            rule :decrement do
                match(:value, '-', '-', ';') do |a,_,_,_|
                    Decrement.new(a)
                end
            end

            rule :operator do
                match("=","=") { |a, b| "#{a}#{b}" }
                match("!","=") { |a, b| "#{a}#{b}" }
                match("<","=") { |a, b| "#{a}#{b}" }
                match(">","=") { |a, b| "#{a}#{b}" }
                match("<") { |x| x }
                match(">") { |x| x }
                match("&","&") { |a, b| "and" }
                match("|","|") { |a, b| "or" }
            end

            rule :print do
                match('PRINT', '(', :value, ')', ';') do |_, _, x, _, _|
                Print.new(x)
                end
            end

            rule :params do
                match(:params, ',', :haram) do |x,_,c|
                    x << c
                    x
                end
                match(:haram) {|x| [x]}
                match(""){|_| []}
            end

            rule :haram do
                match(:type, :identifier) {|a,b| {b => a}}
            end

            rule :type do
                match("int") { |x| x }
                match("float") { |x| x }
                # match("string")
                match("bool") { |x| x }
                match("void") { |x| x }
            end

            rule :values do
                match(:values, ',', :value) do |a,_,b|
                    a << b
                    a
                end
                match(:value) do |x|
                    [x]
                end
            end

            rule :value do
                match(:boolean) { |x| x }
                match(:expr) { |x| x }
                match(Integer)
                match(Float)

            end

            rule :boolean do
                match("True") { |x| x }
                match("False") { |x| x }
            end

            rule :identifier do
                match(/[a-z]+[\w]*/)
            end

            rule :expr do
                match(:expr, '+', :term) { |a, _, b| AritmheticExpression.new(a, '+', b) }
                match(:expr, '-', :term) { |a, _, b| AritmheticExpression.new(a, '-', b) }
                match(:term)
            end

            rule :term do
                match(:term, '*', :expo) { |a, _, b| AritmheticExpression.new(a, '*', b) }
                match(:term, '/', :expo) { |a, _, b| AritmheticExpression.new(a, '/', b) }
                match(:expo)
            end

            rule :expo do
                match(:expo, '*', '*', :num) { |a, _, _, b| AritmheticExpression.new(a, '**', b) }
                match(:num)
            end

            rule :num do
                match(Integer) { |x| CmmInteger.new(x) }
                match('-', Integer) { |_,x| CmmInteger.new(x * -1)}
                match(Float) { |x| CmmFloat.new(x) }
                match('-', Float) { |_,x| CmmFloat.new(x * -1)}
                match(:identifier) do |a|
                    LookUp.new(a)
                end
                match('(', :expr, ')') { |_, a, _| a }
            end
        end
    end

    def parse(str)
        @cmmParser.parse(str)
    end

    def log(state = false)
        if state
            @cmmParser.logger.level = Logger::DEBUG
        else
            @cmmParser.logger.level = Logger::WARN
        end
    end
end

c_minus_minus = CMM.new()
c_minus_minus.log()
cmmFile = File.read("tests.cmm")
c_minus_minus.parse(cmmFile)
