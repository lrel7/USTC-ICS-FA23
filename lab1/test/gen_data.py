import random

with open("test_data.txt", "w") as file:
    for i in range(1000):
        file.write(str(random.randint(1, 65535)) + ":22000197,")
