#!/usr/bin/env ruby

require 'DataCon'
require 'Language'

class Converter
  @@variables = Hash.new
  @@functions = Hash.new
  
  def self.get_variables
    @@variables
  end

 def self.make_while(expression, statement_list = "")
   return DataCon.new("while", expression, "do", statement_list, "end")
 end

 def self.make_if(expression, stmt_list_if = "", stmt_list_else = "", el = true)
   if(el)
     return DataCon.new("if(", expression, ") then", stmt_list_if, "else", stmt_list_else, "end")
   else
     return DataCon.new("if(", expression, ") then", stmt_list_if, "end")
   end
 end

 def self.for_stmt(statement, expression, assignment, statement_list = "")
   return DataCon.new(statement,  "while(", expression,") do", assignment, ";", statement_list, "end;")
 end

 def self.options(literal_expr, cases)
   return DataCon.new("case", literal_expr,  cases)  
 end

 def self.cases(literal_expr, statement_list, cases, default = false)
   if(default)
     return DataCon.new("else", statement_list, cases)
   else
     return DataCon.new("when", literal_expr, "then", statement_list, cases)
   end
 end

 def self.float_literal(dec_digits_1, dec_digits_2)
   return DataCon.new(dec_digits_1, ".", dec_digits_2)
 end

 def self.assignment(ident, opr, expr = DataCon.new("''"))
     new_con = DataCon.new("_assignment(:", ident, ",", opr, ",", expr, ",variables)")
	 new_con.assign_var(ident.sec_block, expr.sec_block)
	 return new_con
 end

 def self.array_assignment(ident, int_literal, opr, expr)
   new_con = DataCon.new("_array_assignment(:", ident ,",", int_literal, ",", opr, ",", expr, ",variables)")
   add_assign(ident, expr, new_con)
   return new_con
 end

 def self.add_assign(ident, expr, con)
	 	con.variables[ident] = Array.new if(!con.variables[ident].is_a?(Array))
		case "#{expr}"
			when /".*"/
				con.variables[ident] << "string"
			when /\d+\.\d+/
				con.variables[ident] << "float"
			when /\d+/
				con.variables[ident] << "int"
			else
				con.variables[ident] << expr
		end
 end
 
 def self.argument_list(expr, arg_list)
   return DataCon.new(expr, arg_list)
 end

 def self.call(primary, argument_list = "")
   return DataCon.new(primary, argument_list)
 end

 def self.function_declaration(type, ident, stmt_list, ret, arg_list = DataCon.new(""))
   new_con = DataCon.new("def", ident, "(", arg_list, ")", stmt_list,  "return",  ret, ";end")
   new_con.func_dec(ident.sec_block, type.sec_block, arg_list.sec_block)
   new_con.ret(ret.sec_block)
   return new_con
 end

 def self.declaration(type, ident, int_literal = DataCon.new(""))
   if(int_literal.empty?)
		case type
			 when "int"
				  expr =  "0"
			 when "string"
				  expr = "''"
			 when "float"
				  expr =  "0.0"
		end
	 else
		expr = "Array.new(#{int_literal})"
	end

   new_con = DataCon.new("_declaration_assignment(:",ident, ",'=',", expr, ",variables)")
   new_con.declare_var(ident.sec_block, type.sec_block)
   return new_con
 end

 def self.declaration_assignment(type, ident, assignment_opr, int_literal, expr)
	new_con = DataCon.new("_declaration_assignment(:",ident,",", assignment_opr,",", expr, ",variables)")
	new_con.declare_var(ident.sec_block, type.sec_block)
	new_con.assign_var(ident.sec_block, expr.sec_block)
	return new_con
 end

 def self.binary_or(or_test, and_test)
   return DataCon.new(or_test, "||",  and_test)
 end

 def self.binary_and(and_test, not_test)
   return DataCon.new(and_test, "&&", not_test)
 end

 def self.comparision(or_expr_1, comp_opr, or_expr_2)
   return DataCon.new(or_expr_1, comp_opr, or_expr_2)
 end

 def self.binary_not(not_text)
   return DataCon.new("!", not_text)
 end

 def self.init_func(code_block, argument_list = "")
   arg_list = ""
   instance_eval("[#{argument_list}]").each do | arg |	
   	arg_list += "variables[:#{arg}] = #{arg};"
   end
   return DataCon.new("variables = Hash.new;", arg_list, code_block)
 end

 def self.arith_expr(expr_1, opr, expr_2)
   DataCon.new(expr_1, opr, expr_2)
 end

 def self.call_func(ident, arg_list = DataCon.new(""))
 	k = DataCon.new(ident, "(", arg_list, ")").sec("f:", ident)
	k.call_func(ident.sec_block, arg_list.sec_block)
	return k
 end

end




