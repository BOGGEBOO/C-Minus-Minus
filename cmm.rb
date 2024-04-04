#!/usr/bin/env ruby

require 'logger'

require './nodes'



class Rule

  Match = Struct.new :pattern, :block

  def initialize(name, parser)
    @logger=Logger.new(STDOUT)
    @name = name
    @parser = parser
    @matches = []
    @lrmatches = []
  end


  def match(*pattern, &block)
    match = Match.new(pattern, block)
    if pattern[0] == @name
      pattern.shift
      @lrmatches << match
    else
      @matches << match
    end
  end


  def parse
    match_result = try_matches(@matches)
    return nil unless match_result
    loop do
      result = try_matches(@lrmatches, match_result)
      return match_result unless result
      match_result = result
    end
  end



  private

  def try_matches(matches, pre_result = nil)
    match_result = nil
    start = @parser.pos
    matches.each do |match|
      result = pre_result ? [pre_result] : []
      match.pattern.each_with_index do |token,index|
        if @parser.rules[token]
          result << @parser.rules[token].parse
          unless result.last
            result = nil
            break
          end
          @logger.debug("Matched '#{@name} = #{match.pattern[index..-1].inspect}'")
        else
          nt = @parser.expect(token)
          if nt
            result << nt
            if @lrmatches.include?(match.pattern) then
              pattern=[@name]+match.pattern
            else
              pattern=match.pattern
            end
            @logger.debug("Matched token '#{nt}' as part of rule '#{@name} <= #{pattern.inspect}'")
          else
            result = nil
            break
          end
        end
      end
      if result
        if match.block
          match_result = match.block.call(*result)
        else
          match_result = result[0]
        end
        @logger.debug("'#{@parser.string[start..@parser.pos-1]}' matched '#{@name}' and generated '#{match_result.inspect}'") unless match_result.nil?
        break
      else
        @parser.pos = start
      end
    end

    return match_result
  end
end


class Parser


  attr_accessor :pos
  attr_reader :rules,:string
  class ParseError < RuntimeError; end
  def initialize(language_name, &block)
    @logger=Logger.new(STDOUT)
    @lex_tokens = []
    @rules = {}
    @start = nil
    @language_name=language_name
    instance_eval(&block)
  end

  def tokenize(string)
    @tokens = []
    @string=string.clone
    until string.empty?
      raise ParseError, "unable to lex '#{string}" unless @lex_tokens.any? do |tok|
        match = tok.pattern.match(string)
        if match
          @logger.debug("Token #{match[0]} consumed")
          @tokens << tok.block.call(match.to_s) if tok.block
          string = match.post_match
          true
        else
          false
        end # if
      end # raise
    end # until
  end

  def parse(string)
    tokenize(string)
    @pos = 0
    @max_pos = 0
    @expected = []
    result = @start.parse
    if @pos != @tokens.size
      raise ParseError, "Parse error. expected: '#{@expected.join(', ')}', found '#{@tokens[@max_pos]}'"
    end
    return result
  end

  def next_token
    @pos += 1
    return @tokens[@pos - 1]
  end

  def expect(tok)
    t = next_token
    if @pos - 1 > @max_pos
      @max_pos = @pos - 1
      @expected = []
    end
    return t if tok === t
    @expected << tok if @max_pos == @pos - 1 && !@expected.include?(tok)
    return nil
  end

  def to_s
    "Parser for #{@language_name}"
  end

  private

  LexToken = Struct.new(:pattern, :block)

  def token(pattern, &block)
    @lex_tokens << LexToken.new(Regexp.new('\\A' + pattern.source), block)
  end

  def start(name, &block)
    rule(name, &block)
    @start = @rules[name]
  end

  def rule(name,&block)
    @current_rule = Rule.new(name, self)
    @rules[name] = @current_rule
    instance_eval &block
    @current_rule = nil
  end

  def match(*pattern, &block)
    @current_rule.send(:match,*pattern,&block)
  end
end



class CMM
  def initialize()
    @cmmParser = Parser.new("CMM") do
      token(/\s+/)
      token(/\d+/) { | x | x.to_i }
      token(/./) { | x | x }
      token(/\*{2}/) { "**" }

      start :expr do
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
        match(:expo, '**', :num) { |a, _, b| AritmheticExpression.new(a, '**', b) }
        match(:num)
      end

      rule :num do
        match(Integer) { | x | CmmInteger.new(x) }
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



class DiceRoller


  def DiceRoller.roll(times, sides)
    (1..times).inject(0) {|sum, _| sum + rand(sides) + 1 }
  end

  def initialize
    @diceParser = Parser.new("dice roller") do
      token(/\s+/)
      token(/\d+/) {|m| m.to_i }
      token(/./) {|m| m }

      start :expr do
        match(:expr, '+', :term) {|a, _, b| a + b }
        match(:expr, '-', :term) {|a, _, b| a - b }
        match(:term)
      end

      rule :term do
        match(:term, '*', :dice) {|a, _, b| a * b }
        match(:term, '/', :dice) {|a, _, b| a / b }
        match(:dice)
      end

      rule :dice do
        match(:atom, 'd', :sides) {|a, _, b| DiceRoller.roll(a, b) }
        match('d', :sides) {|_, b| DiceRoller.roll(1, b) }
        match(:atom)
      end

      rule :sides do
        match('%') { 100 }
        match(:atom)
      end

      rule :atom do
        match(Integer)
        match('(', :expr, ')') {|_, a, _| a }
      end
    end
  end

  def done(str)
    ["quit","exit","bye",""].include?(str.chomp)
  end

  def roll
    print "[diceroller] "
    str=gets
    if done(str) then
      puts "Bye."
    else
      puts "=> #{@diceParser.parse str}"
      roll
    end
  end
end

class ConstraintParser < Parser
  class Variable; end

  def initialize
    @connectors={}
    @parser=super("constraints") do
      token(/\s+/)
      token(/[[:alpha:]]+/) do |connector|
        @connectors[connector] ||= Connector.new(connector)
      end
      token(/\d+/) do |constant|
        @connectors[constant] ||= ConstantConnector.new(constant,constant.to_i)
      end
      token(/./) { |m| m }

      start :statement do

        match(:expr, '=', :expr) do |lh, _, rh|
          replace_conn(lh, rh)
          @connectors.values.reject do |conn|
            conn.is_a?(ConstantConnector) or (not (/^\w+$/ =~ conn.name))
            end
        end

      end

      rule :expr do

        match(:expr, '+', :term) do |a, _, b|
          conn_a,conn_b,conn_c=get_connectors(a,'+',b)
          Adder.new(conn_a,conn_b,conn_c)
        end

        match(:expr, '-', :term) do |a, _, b|
          conn_a,conn_b,conn_c=get_connectors(a,'-',b)
          # a-b=c <=> a=b+c
          Subtractor.new(conn_a,conn_b,conn_c)
        end

        match(:term)

      end

      rule :term do

        match(:term, '*', :atom) do |a, _, b|
          conn_a,conn_b,conn_c=get_connectors(a,'*',b)
          Multiplier.new(conn_a,conn_b,conn_c)
        end

        match(:term, '/', :atom) do |a, _, b|
          conn_a,conn_b,conn_c=get_connectors(a,'/',b)
          # a/b=c <=> b*c=a
          Divider.new(conn_a,conn_b,conn_c)
        end

        match(:atom)

      end

      rule :atom do
        match(Connector)
        match('(', :expr, ')') {|_, a, _| a }
      end
    end
  end

  def get_connectors(conn_a,op,conn_b)

    conn_a = get_connector(conn_a)
    conn_b = get_connector(conn_b)

    name_c="#{conn_a.name}#{op}#{conn_b.name}"
    conn_c=Connector.new(name_c)
    @connectors[name_c]=conn_c
    [conn_a,conn_b,conn_c]
  end

   def get_connector(side)
    if side.is_a?(ArithmeticConstraint) then
      return side.out
    else
      return side
    end
   end

  def replace_conn(lh,rh)
    puts "WWWWW"
    @logger.debug(lh)
    @logger.debug(rh)
    lh_conn,rh_conn=[get_connector(lh),get_connector(rh)]
    @logger.debug(lh_conn)
    @logger.debug(rh_conn)
    conn,exp=[nil,nil]
    if rh.is_a?(ArithmeticConstraint) then
      puts("RH")
      exp,conn=rh,lh_conn
      @connectors.delete(rh_conn.name)
    elsif lh.is_a?(ArithmeticConstraint) then
           puts("LH")
           exp,conn=lh,rh_conn
           @connectors.delete(lh_conn.name)
    end
    exp.out=conn
    conn.add_constraint(exp)
    puts "OOOOO"
    @logger.debug(lh)
    @logger.debug(exp)
    @logger.debug(conn)
  end

  def parse(str)
    @connectors={}
    super(str)
  end

end
