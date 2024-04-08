#!/usr/bin/env ruby
require './rdparse'
require './nodes'


class CMM

    @@var_dupster = {}
    @@func_dumpster = {}
    @@executive_dumpster = []

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
                puts "\n\n\n"
                puts @@executive_dumpster

                x.evaluate 
                puts @@var_dupster
            }
            end

            # spara code_block noder(print,assign) i container,
            # gå i genom i :program med .evaluate

            rule :func_declare do
                match(:main) { |x| MainFunction.new(@@executive_dumpster) }
                # match(:type, :identifier, '(', :params ')', '{', :code_block, '}') {}
            end

            rule :main do
                match(:type, 'main', '(', ')', '{', '}') { 0 }
                match(:type, 'main', '(', ')', '{', :code_blocks, '}') # { |_, _, _, _, _, x, _| x }
            end

            rule :code_blocks do
                match(:code_blocks, :code_block) # {CodeBlock.new()}
                match(:code_block)
            end

            rule :code_block do
                match(:assign)
                match(:print)
            end

            rule :assign do
                match(:type, :identifier, '=', :value, ';') do |type, identifier, _, value, _|
                    @@executive_dumpster << Assignment.new(identifier, value, type)
                end
            end

            rule :print do
                match('PRINT', '(', :value, ')', ';') do |_, _, x, _, _|
                    @@executive_dumpster << Print.new(x)
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
                    # puts "\n\n\n"
                    # puts @@var_dupster[a]
                    # puts "\n\n\n"
                    LookUp.new(a)
                end
                match('(', :expr, ')') { |_, a, _| a }
            end

        end
    end

    def parse(str)
        @cmmParser.parse(str)
    end
end

c_minus_minus = CMM.new()
cmmFile = File.read("tests.cmm")
p c_minus_minus.parse(cmmFile)
