
output = open("output.arff", 'w')
with open("seeds_dataset.txt", 'r') as in_file:
	for line in in_file:
		s = line.split() 	# We split the line
		s = ",".join(s)		# Comma separated value format
		s = s + "\n"		# newline
		output.write(s)

output.close()
