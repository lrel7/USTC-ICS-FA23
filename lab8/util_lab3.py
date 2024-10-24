with open("lab3_data.txt", "r") as f:
    lines = f.read()

lines = lines.split("\n")
output_lines = []
for line in lines:
    data = line.split()
    output_lines.append(":".join(data))

with open("lab3_data_lc3.txt", "w") as f:
    f.write(",".join(output_lines))