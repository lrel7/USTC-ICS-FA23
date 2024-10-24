import random

nums = []
for _ in range(8):
    nums.append(random.randint(0, 100))
    nums.append(random.randint(101, 1000))
    nums.append(random.randint(1001, 10000))
    nums.append(random.randint(10001, 32767))
nums.pop()
nums.append(5)
nums.append(15)
nums.append(6280)

with open("lab1_data.txt", "w") as f:
    for num in nums:
        f.write(str(num) + "\n")
    
with open("lab1_data_lc3.txt", "w") as f:
    for num in nums:
        f.write(str(num) + ":22000197,")