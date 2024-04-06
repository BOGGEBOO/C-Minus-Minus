#!/usr/bin/env ruby
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
variables = Hash.new;variables[:] = ;_declaration_assignment(:kaka,'=',"baajs",variables);variables = Hash.new;variables[:] = ;_declaration_assignment(:kaka,'=',5,variables);variables = Hash.new;variables[:] = ;_declaration_assignment(:kaka,'=',5.0,variables);variables = Hash.new;variables[:] = ;_declaration_assignment(:kaka,'=',"",variables);variables = Hash.new;variables[:] = ;_declaration_assignment(:kaka,'=',"#$^!@$^^&",variables);deffunction()variables = Hash.new;variables[:] = ;break;return5;endvariables = Hash.new;variables[:] = ;_declaration_assignment(:lala,'=',function(),variables);