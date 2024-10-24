with open("test.txt", "w") as f:
    # lab1~3的输入数据
    for data_file in ["lab1_data.txt", "lab2_data.txt", "lab3_data.txt"]:
        with open(data_file, "r") as input_file:
            f.write(input_file.read())
    # lab4的输入数据
    for i in range(13):
        f.write(str(i) + "\n") 
    for i in range(23):
        f.write("0\n")