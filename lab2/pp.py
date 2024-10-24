def pingpong(v, d):
    if d:
        v_next = (2 * v + 2) % 4096
    else:
        v_next = (2 * v - 2) % 4096

    if v_next % 8 == 0 or v_next % 10 == 8:
        d_next = not d
    else:
        d_next = d

    return v_next, d_next

v = 3
d = True

with open("result.txt", "w") as f:
    for i in range(1, 1000):
        f.write("f(" + str(i) + ")=" + str(v) + " direction=" + str(d) + "\n")
        v, d = pingpong(v, d)
