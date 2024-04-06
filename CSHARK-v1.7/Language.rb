require 'rdparse'
require 'DataCon'
require 'Converter'
require 'debug_stack'

class Language
       
  def initialize
    @diceParser = Parser.new("dice roller") do
      token(/\s+/)
      token(/\w+/){|m| m}
	  token(/\d+\.\d+/){|m|m}
      token(/\d+/) {|m| m }
      token(/((\+\+)|(--)|(==)|(\+=)|(-=)|(\*=)|(\/=)|(>=)|(<=)|(!=)|(&&)|(\|\|))/){|m| m}
      token(/".*?"/) {|m| m}
      token(/./) {|m| m}
      
     Language.init()
     
      start :program do
        match(:program_parts) do |program| 
          file = File.open('program.rb', 'a')
          file.write(program)
          file.close
		  stack = StackDebug.new
		  stack.run(program.stack)
		  puts stack.errors
		  puts stack.warnings
        end
      end

      rule :program_parts do
        match(:function_declarations, :main){|functions, main| DataCon.new(functions, Converter.init_func(main))}
        match(:main){|code_block| Converter.init_func(code_block)}
       end

      rule :main do
        match('int', 'main', '(',')', '>','<'){ DataCon.new("")}
        match('int', 'main', '(',')', '>',:statement_list, '<'){|_,_,_,_,_,stmt_list,_| stmt_list}
      end

      rule :statement_list do
        match(:statement, :statement_list){|stmt, stmt_list| DataCon.new(stmt, stmt_list)}
        match(:statement){|m|m}
      end

      rule :statement do 
        match('break', ';'){ DataCon.new("break;")}
        match(:variable_declaration, ';'){|var_dec, _| DataCon.new(var_dec,";")}
        match(:assignment, ';'){|assignment, _| DataCon.new(assignment,";")}
        match(:if_stmt){|m| m}
        match(:for_stmt){|m| m}
        match(:options){|m| m}
        match(:while){|m|m}
        match(:call, ';'){|m, _| DataCon.new(m,";")}
      end
      
      rule :variable_declaration do
        match(:declaration_assignment) {|m|m}
        match(:type, :identifier, '[', :int_literal, ']') do 
          |type, identifier, _, int_literal, _| 
          Converter.declaration(type, identifier, int_literal)
	end
        match(:type, :identifier)  {|type, identifier| Converter.declaration(type, identifier)}
      end

      rule :declaration_assignment do
        match(:type, :identifier, :assignment_opr, :expression) do 
          |type, identifier, assignment_opr, expression| 
          Converter.declaration_assignment(type, identifier, assignment_opr, "", expression) 
	end

        match(:type, :identifier, '[', :expression, ']',  '=', :array_assignment) do 
          |type, identifier, _, int_literal, _, _, array_assignment| 
          Converter.declaration_assignment(type, identifier, DataCon.new('"="'), int_literal, array_assignment)
	end

        match(:type, :identifier, '[', :expression, ']', :assignment_opr, :expression) do 
          |type, identifier, _, int_literal, _, assignment_opr, expression| 
          Converter.declaration_assignment(type, identifier, assignment_opr, int_literal, expression)
	end
      end

      rule :expression do
        match(:conditional_expression){|m|m }
      end

      rule :conditional_expression do
        match(:or_test){|m|m }
      end

      rule :or_test do
        match(:or_test, '||', :and_test) {|or_test, _, and_test| Converter.binary_or(or_test, and_test) }
        match(:and_test){|m|m }
       end

      rule :and_test do
        match(:and_test, '&&', :not_test) {|and_test, _, not_test| Converter.binary_and(and_test, not_test)}
        match(:not_test){|m|m }
      end

      rule :while do
        match('while', '(', :expression, ')', '>', '<' ) {|_,_,expr,_,_| Converter.make_while()}
        match('while', '(', :expression, ')', '>', :statement_list, '<' ) do 
          |_,_,expr,_,_,stmt,_| 
          Converter.make_while(expr, stmt)
        end
      end
      
      rule :not_test do
        match('!', :not_test) {|_, not_test| Converter.binary_not(not_test)}
        match(:comparision){|m|m }
      end

      rule :comparision do
        match(:or_expr, :comp_operator, :or_expr) {|expr_1, opr, expr_2| Converter.comparsion(expr_1, opr, expr_2)}
        match(:or_expr){|m|m }
      end

      rule :comp_operator do
        match('<') {|m| DataCon.new(m) }
        match('>') {|m| DataCon.new(m) }
        match('==') {|m| DataCon.new(m) }
        match('>=') {|m| DataCon.new(m) }
        match('<=') {|m| DataCon.new(m) }
        match('!=') {|m| DataCon.new(m) }
      end

      rule :or_expr do
        match(:a_expr, '|', :a_expr)
        match(:a_expr){|m|m }
      end

      rule :array_assignment do
        match('>', '<') {DataCon.new("'[]'")}
        match('>', :argument_list, '<'){|_,m, _| DataCon.new("[#{m}]")}
      end

      rule :a_expr do
        match(:a_expr, '+', :m_expr){|a_expr, _, m_expr| Converter.arith_expr(a_expr, " + ",  m_expr)}
        match(:a_expr, '-', :m_expr){|a_expr, _, m_expr| Converter.arith_expr(a_expr, " - ", m_expr)}
        match(:m_expr){|m|m }
      end

      rule :m_expr do
        match(:m_expr, '*', :u_expr) {|m_expr, _, u_expr| Converter.arith_expr(m_expr, " * ", u_expr)}
        match(:m_expr, '/', :u_expr) {|m_expr, _, u_expr| Converter.arith_expr(m_expr, " / ", u_expr)}
        match(:u_expr){|m|m }
      end

      rule :u_expr do
        match('-', :primary) {|_, primary| Converter.arith_expr("", "-", primary)}
        match('+', :primary) {|_, primary| Converter.arith_expr("", "+", primary)}
        match(:primary){|m|m }
      end

      rule :primary do
        match(:atom){|m|m }
      end

      rule :return do
        match(:expression){|m|m }
      end

      rule :function_declarations do
        match(:function_declaration, :function_declarations){|function, functions| DataCon.new(function, functions)}
        match(:function_declaration){|function| function}
      end

      rule :func_arg_list do
      	match(:type, :identifier, ',', :func_arg_list){|type, ident, _, arg_list| DataCon.new(ident,",", arg_list)}
		match(:type, :identifier){|type, ident| ident}
      end

      rule :function_declaration do
        match(:type, :identifier, '(', :func_arg_list, ')', '>', :statement_list, 'return', :return , ';', '<' ) do 
          |type, ident, _, arg_list, _, _, stmt_list, _, ret, _, _| 
          Converter.function_declaration(type, ident, Converter.init_func(stmt_list, arg_list), ret, arg_list)
        end

        match(:type, :identifier, '(', ')', '>', :statement_list, 'return', :return , ';', '<' ) do 
          |type, ident, _, _, _, stmt_list, _, ret, _, _| 
          Converter.function_declaration(type, ident, Converter.init_func(stmt_list), ret)
        end

		match(:type, :identifier, '(', :func_arg_list, ')', '>', 'return', :return, ';', '<') do
			|type, ident, _, arg_list, _, _, _, ret, _, _|
			Converter.function_declaration(type, ident, Converter.init_func(DataCon.new(""), arg_list), ret)
		end

		match(:type, :identifier, '(',  ')', '>', 'return', :return, ';', '<') do
			|type, ident, _, _, _, _, ret, _, _|
			Converter.function_declaration(type, ident, Converter.init_func(DataCon.new(""), ret)

      end
      
      rule :call do
        match(:identifier, '(', ')') do 
		|primary, _| 
		Converter.call_func(primary)
		end

        match(:identifier, '(', :argument_list, ')') do
          |primary, _, arg_list, _|
		  Converter.call_func(primary, arg_list)
        end
      end

      rule :atom do
        match(:literal_expr){|m|m }
      end

      rule :argument_list do
        match(:expression, ',', :argument_list){|expr, _, arg_list| Converter.argument_list(expr, arg_list)}
        match(:expression){|m|m }
      end
     
      rule :int_literal do
        match(:decimal_digits){|m|m }
      end

      rule :decimal_digits do
        match(/[0-9]+/){|m| DataCon.new(m)}
      end
      
      rule :for_stmt do
        match('for', '(', :statement, ';', :expression, ';', :assignment, ')', '>', :statement_list, '<') do 
          |_, _, stmt, _,expr, _, assignment, _, _, stmt_list,_ | 
          Converter.for_stmt(stmt, expr, assignment, stmt_list) 
        end

        match('for' ,'(', :statement, ';', :expression, ';', :assignment, ')', '>','<') do 
          |_, _, stmt, _, expr, _, assignment, _, _, _| 
          Converter.for_stmt(stmt, expr, assignment) 
        end
      end

      rule :options do
        match('options', '(', :literal_expr, ')', '>', :cases) do 
          |_, _, literal_expr, _, _, cases| 
          Converter.options(literal_expr, cases)
        end
      end

      rule :cases do
        match('case', :literal_expr, ':', :statement_list, :cases) do 
          |_, literal_expr, _, stmt_list, cases| 
          Converterases(literal_expr, stmt_list, cases)
        end

        match('default', ':', :statement_list, :cases) do 
          |_, _, stmt_list, cases| 
          Converterases("", stmt_list, cases, true)
        end

        match('<') {DataCon.new("end")}
      end

      rule :if_stmt do
        match('if', '(', :expression, ')', '>', :statement_list, '<', 'else', '>', :statement_list, '<') do 
          |_, _, expr, _, _, stmt_list_if, _, _, _, stmt_list_else, _ |  
          Converter.make_if(expr, stmt_list_if, stmt_list_else)
        end

        match('if', '(', :expression, ')', '>', :statement_list, '<', 'else', '>','<') do
          |_, _, expr, _, _, stmt_list_if, _, _, _,_ | 
          Converter.make_if(expr, stmt_list_if)
        end
        
        match('if', '(', :expression, ')', '>','<', 'else', '>', :statement_list, '<') do
          |_, _, expr, _, _, _, _, _, stmt_list_else, _ |
          Converter.make_if(expr,  "", stmt_list_else)
        end

        match('if', '(', :expression, ')', '>','<', 'else', '>','<') do 
          |_, _, expr, _, _, _, _, _, _|
          Converter.make_if(expr)
        end

        match('if', '(', :expression, ')', '>','<' ) do 
          |_, _, expr, _, _, _|
          Converter.make_if(expr, "", "", false)
        end

        match('if', '(', :expression, ')', '>', :statement_list, '<' ) do 
          |_, _, expr, _, _, stmt_list_if, _|
          Converter.make_if(expr, stmt_list_if, "", false)
        end
      end

      rule :string do
        match('""') {DataCon.new('""')}
        match(/".*?"/) {|m| DataCon.new(m)}
      end

      rule :literal_expr do
	match(:call){|m|m}
        match(:float_literal) {|m| m}
        match(:int_literal) {|m| m}
        match(:string){|m| m}
	match(:array_identifier){|m|m}
        match(:variable_identifier){|m|m }
      end

      rule :float_literal do
        match(:decimal_digits, '.', :decimal_digits) do 
          |dec_digits_1, _, dec_digits_2| 
          Converter.float_literal(dec_digits_1, dec_digits_2)
        end
      end

      rule :type do
        match('int') {|m| DataCon.new(m)}
        match('float') {|m| DataCon.new(m)}
        match('string'){|m| DataCon.new(m)}
      end

      rule :identifier do
        match(/[A-z0-9]+/){|m| DataCon.new(m)}
      end

      rule :array_identifier do
      match(/[A-z0-9]+/, '[', /\d+/, ']') do 
        |ident, _, literal, _| 
        DataCon.new("_get_variable(:#{ident}, variables)[#{literal}]")
        end
      end
	
      rule :variable_identifier do
        match(/-?[A-z0-9]+/) do |ident| 
		k = DataCon.new("_get_variable(:", ident, ",variables)")
		k.sec("v:",ident)
		k
		end
      end

      rule :assignment_opr do
        match('='){|opr| DataCon.new("'#{opr}'")}
        match('+='){|opr| DataCon.new("'#{opr}'")}
        match('-='){|opr| DataCon.new("'#{opr}'")}
        match('*='){|opr| DataCon.new("'#{opr}'")}
        match('/='){|opr| DataCon.new("'#{opr}'")}
      end

i
      rule :increment_opr do
        match('++'){|opr| DataCon.new("'#{opr}'")}
        match('--'){|opr| DataCon.new("'#{opr}'")}
      end

      rule :assignment do
        match(:identifier, :assignment_opr, :expression) do
          |ident, opr, expr| 
          Converter.assignment(ident, opr, expr)
        end

        match(:identifier, :increment_opr) do
          |ident, opr|
          Converter.assignment(ident, opr)
        end
      
        match(:identifier, '[', :int_literal, ']', :assignment_opr, :expression) do 
          |ident, _, int_literal, _, opr, expr|
          Converter.array_assignment(ident, int_literal, opr, expr)
        end
      end
    end
   end


  def Language.init
    @variables, @assignments,  @declaration_assignments = Array.new, Array.new, Array.new
    file = File.open('program.rb', 'w')
    file.write('#!/usr/bin/env ruby
class Array
  def [](len)
    if(!len.is_a?(Fixnum))
      puts "Array operator [] can only take Fixnum expressions"
      exit
    end
    if(len > length - 1 || len < 0)
      puts "Fixnum is out of range"
      exit
    end
    values_at(len)
  end
end

def _assignment(ident, opr, expression, variables)
  if(!variables.include?(ident))
    puts "Assignment to a non existing variable"
    exit
  end
  instance_eval("variables[:#{ident}] #{opr} #{expression.inspect}")
end

def _declaration_assignment(ident, opr, expression, variables)
  if(variables.include?(ident))
    puts "The variable is already declared"
    exit
  end
  instance_eval("variables[:#{ident}] #{opr} #{expression.inspect}")
end

def _get_variable(ident, variables)
  if(!variables.include?(ident))
    puts "Variable you are trying to get does not exist"
    exit
  end
  return variables[ident]
end

def _array_assignment(ident, int_literal, opr, expr, variables)
  exit if(!variables.include?(ident))
  instance_eval("variables[:#{ident}][#{int_literal}] #{opr} #{expr.inspect}")
end
')
file.close()
    end
  
  def done(str)
    ["quit","exit","bye",""].include?(str.chomp)
  end
  
  def roll
    print "[diceroller] "
    str = gets
    if done(str) then
      puts "Bye."
    else
      #@diceParser.logger.level = Logger::WARN
      puts "=> #{@diceParser.parse str}"
      roll
    end
  end

  def compile(str)
  	begin
    	@diceParser.logger.level = Logger::WARN
    	@diceParser.parse str
	rescue Parser::ParseError => detail
		return "Syntax error"
	end
	return nil
  end 

  def log(state = false)
    if state
     @diceParser.logger.level = Logger::DEBUG
    else
      @diceParser.logger.level = Logger::WARN
    end
  end
end

