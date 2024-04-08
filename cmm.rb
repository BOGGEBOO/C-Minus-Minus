#!/usr/bin/env ruby

require './nodes'
require_relative './rdparse'

class CMM
  def initialize()

    @@var_dupster = {}
    @@func_dumpster = {}


    @cmmParser = Parser.new("CMM") do
      token(/\s+/)
      token(/\d+\.\d+/) { | x | x.to_f }
      token(/\d+/) { | x | x.to_i }
      token(/\w+/) { | x | x }
      token(/;/) { | x | x }
      token(/True/) { | x | x }
      token(/False/) { | x | x }

      #Längst ner yo
      token(/./) { | x | x }


      # rule :var_declaration do
      #   match(:type, :name, '=', :val, ';') { |a, b, _, c, _ | "do the thing" }
      # end
      start :program do
        match(:func_declare)
      end


      #spara code_block noder(print,assign) i container,
      #gå i genom i :program med .evaluate



      # NOTE! :expr är placeholder
      rule :func_declare do
        match(:main)
        #match(:type, :identifier, '(', :params ')', '{', :code_block, '}') {}
      end

      rule :main do
        match(:type, 'main', '(', ')', '{', '}') { 0 }
        match(:type, 'main', '(', ')', '{', :code_blocks,'}')  { |_,_,_,_,_,x,_| x }
      end

      rule :code_blocks do
        match(:code_block, :code_blocks) #{CodeBlock.new()}
        match(:code_block)
      end

      rule :code_block do
        match(:assign)
        match(:print)
      end

      rule :assign do
        match(:type, :identifier, '=', :value, ';') { |type,identifier,_,value,_|
          case type
          when "int"
            @@var_dupster[identifier] = CmmInteger.new(value)
          when "float"
            @@var_dupster[identifier] = CmmFloat.new(value)
          when "bool"
            #cant send false from :value
            if value == "True"
              temp = true
            elsif value == "False"
              temp = false
            end
            @@var_dupster[identifier] = CmmBoolean.new(temp)
          end

          p @@var_dupster
      }
      end

      rule :print do
        match('PRINT', '(', :value, ')', ';') { | _,_,x,_,_ | Print.new(x) }
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
        #match("string")
        match("bool") { |x| x }
        match("void") { |x| x }
      end

      rule :value do
        match(Integer)
        match(Float)
        match("True") { |x| x }
        match("False") { |x| x }
        match(:expr) {|x| x.evaluate}
      end

      rule :identifier do
        match(/[a-z]+[\w]+/) # {spara undan namn}
      end

      rule :expr do
        match(:expr, '+', :term) { |a, _, b| AritmheticExpression.new(a, '+', b) }
        match(:expr, '-', :term) { |a, _, b| AritmheticExpression.new(a, '-', b) }
        match(:term)
      end

      rule :term do
        match(:expo)
        match(:term, '*', :expo) { |a, _, b| AritmheticExpression.new(a, '*', b) }
        match(:term, '/', :expo) { |a, _, b| AritmheticExpression.new(a, '/', b) }

      end

      rule :expo do
        match(:expo, '*', '*', :num) { |a, _, _, b| AritmheticExpression.new(a, '**', b) }
        match(:num)
      end

      rule :num do
        match(Integer) { | x | CmmInteger.new(x) }
        match('(', :expr, ')') { |_, a, _| a }
        match(:identifier) { | a | @@var_dupster[a] }
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
