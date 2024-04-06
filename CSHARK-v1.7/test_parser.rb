#!/usr/bin/env ruby

require 'Language'
require 'test/unit'

class Testfiles < Test::Unit::TestCase
	
	@@lang = Language.new

	def test_declaration_assignment
		assert_equal(@@lang.compile('int main()>string kaka = "baajs";<'), nil)
		assert_equal(@@lang.compile('int main()>int kaka = 5;<'), nil)
		assert_equal(@@lang.compile('int main()>float kaka = 5.0;<'), nil)
		assert_equal(@@lang.compile('int main()>string kaka = "";<'), nil)
		assert_equal(@@lang.compile('int main()>string kaka = "#$^!@$^^&";<'), nil)
		assert_equal(@@lang.compile('int function()>break; return 5;<int main()>int lala = function();<'), nil)
	end

	def test_function_args
		assert_equal(@@lang.compile('int function(int lala)>break; return 5;<int main()>function(5.0);<'), nil)
	end
end
	
