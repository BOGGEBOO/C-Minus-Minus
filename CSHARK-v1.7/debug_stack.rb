
class StackDebug

	attr_reader :errors, :warnings
	

	def initialize
		@func_vars, @variables = Hash.new, Hash.new
		@errors, @warnings = Array.new, Array.new
	end

	def run(stack)
		puts stack.inspect
			stack.each do | op |
				case op.first
					when "f"
						func_dec(op[1], op[2], op[3])
					when "d"
						declare_var(op[1], op[2])
					when "a"
						assign_var(op[1], op[2])
					when "r"
						ret(op[1])
					when "c"
						call_func(op[1], op[2])
				end
			end
						
	end

	def func_dec(name, type, args)
			@func_vars[name] = {"type" => type, "args" => args}
			@current = type
			@variables = Hash.new
	end

	def declare_var(name, type)
		@variables[name] = type
	end

	def replace_expr(expr)
		puts expr.inspect
		expr.collect! do | elem |
			puts "elemm = #{elem}"
			case elem[0..1]
				when 'f:'
					@func_vars[elem[2..-1]]["type"]
				when 'v:'
					@variables[elem[2..-1]]
			end
			elem
		end
	end
	
	def check_expr(type, expr)
		puts "type = #{type} expr = #{expr}"
		expr.each do | elem |
			case type
				when "string"
					if(elem =~ /(int|float)/)
						@errors << "Can't assign #{$1} to string"
					end
				when "int"
					if(elem == "string")
						@errors << "Can't assign string to int"
					elsif(elem == "float")
						@warnings << "Assign float to int, value will be rounded"
					end
			end
		end
	end
	
	def ret(expr)
		check_expr(@current, expr)
	end

	def call_func(name, args)
		puts "name = #{name} #{@func_vars.inspect}"
		puts "class = #{name.class}"
		if(@func_vars[name]["type"] == nil)
			@errors << "Function #{name} is not declared"
			return
		end
		puts "func_args #{@func_vars[name]["args"].length} given args = #{args.length}"
		if(@func_vars[name]["args"].length < args.length)
			@errors << "Too many arguments given to function #{name}"
			return
		elsif(@func_vars[name]["args"].length > args.length)
			@errors << "Too few arguments given to function #{name}"
			return
		end

		args.each_with_index do | arg, index |
			replace_expr(arg)
			check_expr(@func_vars[name]["args"][index], arg)
		end
	end
			
	def assign_var(name, expr)
		puts expr.inspect
		replace_expr(expr)
		if(@variables[name] == nil)
			@errors << "Variable #{name} not declared"
			return
		end

		check_expr(@variables[name], expr)
	end

end
