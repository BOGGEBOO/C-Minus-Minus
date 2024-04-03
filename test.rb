input_file = ARGV[0]

input = File.read(input_file)

print eval(input)
