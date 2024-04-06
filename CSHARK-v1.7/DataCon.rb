
require 'logger'

class DataCon

  attr_accessor :stack, :code_block, :sec_block

  def initialize(*args)
  	@code_block, @sec_block, @stack = String.new, String.new, Array.new
    args.each do |arg| 
      if(arg.is_a?(DataCon))
			@stack += arg.stack
      end
	  if(arg.is_a?(DataCon) && !arg.sec_block.empty?)
			@sec_block += arg.sec_block
	  else
			@sec_block +=  "#{arg}"
	  end

       @code_block += "#{arg}"
    end
  end

  def sec(*args)
  	@sec_block = String.new
  	args.each do | arg|
		if(arg.is_a?(DataCon))
			@sec_block += arg.sec_block
		else
			@sec_block += arg
		end
	end
	return self
  end

  def func_dec(name, type, args)
  	@stack.push(["f", name, type, instance_eval("[#{args}]")])
  end

  def to_s
  	return @code_block
  end

  def expr_replace(expr)
  		puts "expr_replace = #{expr.inspect}"
  				expr.collect! do | op |
			       case "#{op}"
				      when /".*"/
				          "string"
					  when /\d+\.\d+/
				          "float"
				       when /\d+/
						   "int"
					   else	
						   op
					end
				end
				return expr
  end


  def ret(expr)
  	@stack.push(["r", expr_replace(expr.split)])
  end

  def declare_var(name, type)
  	@stack.push(["d", name, type])
  end

  def assign_var(name, expr)
	@stack.push(["a", name, expr_replace(expr.split)])
  end
  
  def call_func(ident, arg_list)
  	@stack.push(["c", ident, instance_eval("[#{arg_list}]")])
  end





 # @@log = Logger.new(STDOUT)
end
