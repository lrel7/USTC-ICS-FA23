#include <bitset>
#include <cstdint>
#include <fstream>
#include <iostream>

// #define LENGTH 1
#define MAXLEN 3000
#define STUDENT_ID_LAST_DIGIT 7

void remove(int16_t*, int16_t&, int16_t, int&);
void put(int16_t*, int16_t&, int16_t, int&);

int16_t lab1(int16_t n) {
    // initialize
    int ret = STUDENT_ID_LAST_DIGIT;  // 返回结果
    if ((n & 1) == 0) {               // 偶数
        n = -n;                       // 负数补码
    }

    // calculation
    for (int i = 0; i < 16; i++) {  // 左移16次
        if (n >= 0) {
            ret++;
        }
        n = n + n;  // 左移1位
    }

    // return value
    return ret;
}

int16_t lab2(int16_t n) {
    // initialize
    int v = 3, d = 2;  // N = 1

    // calculation
    for (int i = 2; i <= n; i++) {  // 从N = 2开始
        v = v + v + d;              // 更新v
        v = v & 4095;               // 对4096取余
        if (v & 7 == 0) {           // v可被8整除
            d = -d;                 // 改变方向
            continue;
        }
        int t = v;
        while (t > 1000) {
            t = t - 1000;
        }
        while (t > 100) {
            t = t - 100;
        }
        while (t > 10) {
            t = t - 10;
        }
        if (t == 8) {  // v的个位为8
            d = -d;    // 改变方向
        }
    }

    // return value
    return v;
}

int16_t lab3(char s1[], char s2[]) {
    // initialize

    // calculation
    while (*s1 != '\0' && *s2 != '\0') {
        if (*s1 == *s2) {  // 两个字符相等, 则继续
            s1++;
            s2++;
        } else {
            break;
        }
    }

    // return value
    return *s1 - *s2;
}

int16_t lab4(int16_t* memory, int16_t n) {
    // initialize
    int16_t state = 0;
    int move = 0;

    // calculation
    remove(memory, state, n, move);

    // return value
    return move;
}

void remove(int16_t* memory, int16_t& state, int16_t n, int& move) {
    // @param memory: 存储状态的数组
    // @param state: 当前状态
    // @param n: 要处理的珠子数
    // @param move: 当前已经作用的次数

    if (n == 0) {  // n == 0, do nothing
        return;
    }
    if (n == 1) {                // n == 1, remove the 1st ring
        state = state + 1;       // flip the rightmost bit from 0 to 1
        memory[move++] = state;  // 存入`memory`
    } else {                     // n >= 2
        remove(memory, state, n - 2, move);
        int addend = 1;
        for (int i = 2; i <= n; i++) {
            addend = addend + addend;
        }
        state = state + addend;  // remove the n-th ring (flip the n-th rightmost bit from 0 to 1)
        memory[move++] = state;  // 存入`memory`
        put(memory, state, n - 2, move);
        remove(memory, state, n - 1, move);
    }
}

void put(int16_t* memory, int16_t& state, int16_t n, int& move) {
    // @param memory: 存储状态的数组
    // @param state: 当前状态
    // @param n: 要处理的珠子数
    // @param move: 当前已经作用的次数

    if (n == 0) {  // n == 0, do nothing
        return;
    }
    if (n == 1) {                // n == 1, put the 1st ring
        state = state - 1;       // the rightmost bit
        memory[move++] = state;  // 存入`memory`
    } else {                     // n >= 2
        put(memory, state, n - 1, move);
        remove(memory, state, n - 2, move);
        int subend = 1;
        for (int i = 2; i <= n; i++) {
            subend = subend + subend;
        }
        state = state - subend;  // remove the n-th ring (flip the n-th rightmost bit from 1 to 0)
        memory[move++] = state;  // 存入`memory`
        put(memory, state, n - 2, move);
    }
}

int main() {
    std::fstream file;
    file.open("test.txt", std::ios::in);

    // lab1
    int16_t n = 0;
    std::cout << "===== lab1 =====" << std::endl;
    for (int i = 0; i < LENGTH; ++i) {
        file >> n;
        std::cout << lab1(n) << std::endl;
    }

    // lab2
    std::cout << "===== lab2 =====" << std::endl;
    for (int i = 0; i < LENGTH; ++i) {
        file >> n;
        std::cout << lab2(n) << std::endl;
    }

    // lab3
    std::cout << "===== lab3 =====" << std::endl;
    char s1[MAXLEN];
    char s2[MAXLEN];
    for (int i = 0; i < LENGTH; ++i) {
        file >> s1 >> s2;
        std::cout << lab3(s1, s2) << std::endl;
    }

    // lab4
    std::cout << "===== lab4 =====" << std::endl;
    int16_t memory[MAXLEN], move;
    for (int i = 0; i < LENGTH; ++i) {
        file >> n;
        int16_t state = 0;
        move = lab4(memory, n);
        for (int j = 0; j < move; ++j) {
            std::cout << std::bitset<16>(memory[j]) << std::endl;
        }
    }

    file.close();
    return 0;
}