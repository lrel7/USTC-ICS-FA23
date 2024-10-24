import random

with open("test_data.txt", "w") as f:
    for i in range (10):
        f.write(str(random.randint(1, 200)) + ", ")

