import re

with open("ans.txt", "r") as input_file:
    lines = input_file.readlines()
    extracted_numbers = [re.split(r'[,\s]+', line.strip())[-1] for line in lines]

# 插入标记行
insert_lines = ["===== lab4 ====="] * 3
output = []

for i in range(3):
    output.append("===== lab" + str(i + 1) + " =====")
    output.extend(extracted_numbers[i*34:(i+1)*34])

output.append("===== lab4 =====\n")

with open("ans_processed.txt", "w") as output_file:
    output_file.write('\n'.join(output))
    with open("lab4_ans.txt", "r") as f:
        lab4_ans = f.read()
    output_file.write(lab4_ans)