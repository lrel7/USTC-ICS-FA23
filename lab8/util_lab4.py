def convert_to_binary(line):
    binary_values = [format(int(x), '016b') for x in line.split(',')]
    return '\n'.join(binary_values)

input_file = "lab4_ans_raw.txt"
output_file = "lab4_ans.txt"

with open(input_file, 'r') as f:
    lines = f.readlines()

with open(output_file, 'w') as f:
    for line in lines:
        binary_line = convert_to_binary(line.strip())
        f.write(binary_line + '\n')
