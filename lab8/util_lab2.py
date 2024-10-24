with open("lab2_data.txt", "r") as f:
    lines = f.readlines()
    combined_line = ','.join(line.strip() for line in lines)

with open("lab2_data_lc3.txt", 'w') as f:
    f.write(combined_line)