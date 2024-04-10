#!/usr/bin/env ruby
require './rdparse'
require './nodes'


class CMM

    @@var_dupster = {}
    @@func_dumpster = {}
    @@executive_dumpster = []
    @@current_scope = []
    @@new_scope = []
    @@using_global = true

    def self.setVar(identifier, value)
        @@var_dupster[identifier] = value
    end

    def self.vars(x)
        return @@var_dupster[x]
    end

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

            # rule :var_declaration do
            #   match(:type, :name, '=', :val, ';') { |a, b, _, c, _ | "do the thing" }
            # end
            start :program do
                match(:func_declare) { |x|
                # @@new_scope.each_with_index do |x, n|
                #     print "\n#{n+1}. "; p x
                # end
                # puts "\n\n\n"
                x.evaluate unless x.class == nil

                #p @@new_scope

            }
            end

            # spara code_block noder(print,assign) i container,
            # gå i genom i :program med .evaluate

            rule :func_declare do
                match(:main) { |x| MainFunction.new(x) unless x.class == nil }
                # match(:type, :identifier, '(', :params ')', '{', :code_block, '}') {}
            end

            rule :main do
                match(:type, /codeGoBr[r]+/, '(', ')', '{', '}') { 0 }
                match(:type, /codeGoBr[r]+/, '(', ')', '{', :code_blocks, '}') { |_, _, _, _, _, x, _| x }
            end

            rule :code_blocks do
                match(:code_blocks, :code_block) { |x, c| CodeBlock.new(x, c)}
                match(:code_block)
            end

            rule :code_block do
                match(:assign)
                match(:print)
                match(:if_statement)
            end

            rule :assign do
                match(:type, :identifier, '=', :value, ';') do |type, identifier, _, value, _|
                    Assignment.new(identifier, value, type)
                end
            end

            rule :if_statement do
                match('if', '(', :if_expr, ')', '{', :code_blocks, '}') do |_,_,a,_,_,b,_|
                    IfStatement.new(a, b, @@var_dupster)
                end
            end

            rule :if_expr do
                match(:value, :operator, :value) do |val1, op, val2|
                    @@executive_dumpster.concat(@@current_scope)
                    @@current_scope = []
                    BinaryExpression.new(val1, op, val2)
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
                match(:haram, :params)
                match(:haram)
                match("")
            end

            rule :haram do
                match(:type, :identifier)
            end

            rule :type do
                match("int") { |x| x }
                match("float") { |x| x }
                # match("string")
                match("bool") { |x| x }
                match("void") { |x| x }
            end

            rule :value do
                match("True") { |x| x }
                match("False") { |x| x }
                match(:expr) { |x| x }
                match(Integer)
                match(Float)

            end

            rule :identifier do
                match(/[a-z]+[\w]+/)  # {spara undan namn}
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
                match(Float) { |x| CmmFloat.new(x) }
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
c_minus_minus.log(false)
cmmFile = File.read("tests.cmm")
c_minus_minus.parse(cmmFile)
