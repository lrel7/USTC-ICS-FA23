#include <fstream>
#include <iostream>
#include <map>
#include <string>
#include <vector>
#include "bitset"
#include "sstream"
#include "unordered_map"

std::vector<std::string> read_asm_file(const std::string& filename);
void write_output_file(const std::string& filename,
                       const std::vector<std::string>& output);
std::vector<std::string> assemble(const std::vector<std::string>& input_lines);
std::string translate_instruction(const std::string& instruction);

// TODO: Define any additional functions you need to implement the assembler,
// e.g. the symbol table.
bool is_command(const std::string&);
int get_immediate_value(const std::string&);
std::string get_immediate(const std::string&, int);
std::string get_register(const std::string&);
std::string get_pc_offset(const std::string&, int, int);

// LC-3指令集以及伪指令
const std::unordered_map<std::string, std::string> commands = {
    {"ADD", "0001"},
    {"AND", "0101"},
    {"BR", "0000111"},
    {"BRNZP", "0000111"},
    {"BRN", "0000100"},
    {"BRZ", "0000010"},
    {"BRP", "0000001"},
    {"BRNZ", "0000110"},
    {"BRNP", "0000101"},
    {"BRZP", "0000011"},
    {"JMP", "1100000"},
    {"JSR", "01001"},
    {"JSRR", "0100000"},
    {"LD", "0010"},
    {"LDI", "1010"},
    {"LDR", "0110"},
    {"LEA", "1110"},
    {"NOT", "1001"},
    {"RET", "1100000111000000"},
    {"RTI", "1000000000000000"},
    {"ST", "0011"},
    {"STI", "1011"},
    {"STR", "0111"},
    {"TRAP", "11110000"},
    {".ORIG", ""},
    {".END", ""},
    {".FILL", ""},
    {".BLKW", ""},
    {".STRINGZ", ""}};
std::vector<int> line_addr;                         // 每行对应的地址
int orig_addr;                                      // 程序起始地址
std::unordered_map<std::string, int> symbol_table;  // 符号表

int main(int argc, char* argv[]) {
    // Command-line argument parsing
    if (argc != 3) {
        std::cerr << "Usage: " << argv[0]
                  << " <input_file.asm> <output_file.txt>" << std::endl;
        return 1;
    }

    std::string input_filename = argv[1];
    std::string output_filename = argv[2];

    // Read the input ASM file
    std::vector<std::string> input_lines = read_asm_file(input_filename);

    // Assemble the input file
    std::vector<std::string> output_lines = assemble(input_lines);

    // Write the output file
    write_output_file(output_filename, output_lines);

    return 0;
}

std::vector<std::string> read_asm_file(const std::string& filename) {
    std::vector<std::string> lines;
    std::string line;
    std::ifstream file(filename);

    if (file.is_open()) {
        while (getline(file, line)) {
            lines.emplace_back(line);
        }
        file.close();
    } else {
        std::cerr << "Unable to open file: " << filename << std::endl;
    }

    return lines;
}

void write_output_file(const std::string& filename,
                       const std::vector<std::string>& output) {
    std::ofstream file(filename);
    if (file.is_open()) {
        for (const auto& line : output) {
            file << line << std::endl;
        }
        file.close();
    } else {
        std::cerr << "Unable to open file: " << filename << std::endl;
    }
}

std::vector<std::string> assemble(const std::vector<std::string>& input_lines) {
    std::vector<std::string> output_lines;

    // TODO: Implement the assembly process
    // Implement the 2-pass process described in textbook.
    std::vector<std::vector<std::string>> file;
    int n = input_lines.size();  // .asm文件行数
    line_addr.resize(n);
    int step;  // 两行之间的地址间隔

    // pass 1
    for (int i = 0; i < n; i++) {
        // 将本行分割成字符串数组`line`
        std::istringstream iss(input_lines[i]);
        std::string token;
        std::vector<std::string> line;
        while (std::getline(iss, token, ' ')) {
            line.emplace_back(token);
        }

        // 计算行地址
        if (i == 1) {
            line_addr[i] = orig_addr;
        } else if (i > 1) {
            line_addr[i] = line_addr[i - 1] + step;
        }

        // label
        if (!is_command(line[0])) {                // 不是指令, 则为符号
            symbol_table[line[0]] = line_addr[i];  // 存储标签和地址的映射关系
            line.erase(line.begin());              // 移除标签
        }

        // pseudo command: .ORIG
        if (line[0] == ".ORIG") {
            orig_addr = get_immediate_value(line[1]);  // 获取程序起始地址
        }
        // pseudo command: .STRINGZ
        else if (line[0] == ".STRINGZ") {
            line[1].erase(line[1].begin());  // 去除开头引号
            line[1].pop_back();              // 去除末尾引号
            step = line[1].size() + 1;       // 为字符串空出位置
        }
        // pseudo command: .BLKW
        else if (line[0] == ".BLKW") {
            step = get_immediate_value(line[1]);  // 腾出地址空间
        }
        // pseudo command: .END
        else if (line[0] == ".END") {
            break;
        }
        // 其余指令
        else {
            step = 1;
        }

        file.emplace_back(line);
    }

    // pass 2
    for (int i = 0; i < file.size(); i++) {
        auto line = file[i];

        // .ORIG
        if (line[0] == ".ORIG") {
            output_lines.emplace_back(get_immediate(line[1], 16));  // 将起始地址转化为二进制字符串
        }
        // .FILL
        else if (line[0] == ".FILL") {
            if (symbol_table.find(line[1]) == symbol_table.end()) {                             // 参数是立即数
                output_lines.emplace_back(get_immediate(line[1], 16));                          // 填充二进制字符串
            } else {                                                                            // 参数是符号
                output_lines.emplace_back(std::bitset<16>(symbol_table[line[1]]).to_string());  // 填充符号对应的地址
            }
        }
        // .STRINGZ
        else if (line[0] == ".STRINGZ") {
            for (auto c : line[1]) {
                output_lines.emplace_back(std::bitset<16>(c).to_string());  // 填充字符的ASCII码
            }
            output_lines.emplace_back(16, '0');  // 填充'\0'
        }
        // .BLKW
        else if (line[0] == ".BLKW") {
            for (int j = line_addr[i]; j < line_addr[i + 1]; j++) {
                output_lines.emplace_back(16, '0');  // 填充全0
            }
        }

        // 实际指令
        else {
            std::string machine_code = commands.at(line[0]);  // 获取opcode(以及一些已知的01串)
            // ADD, AND
            if (line[0] == "ADD" || line[0] == "AND") {
                machine_code += get_register(line[1]);  // DR
                machine_code += get_register(line[2]);  // SR1
                // 第三个参数是寄存器
                if (line[3][0] == 'R') {
                    machine_code += "000";
                    machine_code += get_register(line[3]);  // SR2
                }
                // 第三个参数是立即数
                else {
                    machine_code += "1";
                    machine_code += get_immediate(line[3], 5);  // imm5
                }
            }
            // BR
            else if (line[0][0] == 'B' && line[0][1] == 'R') {
                machine_code += get_pc_offset(line[1], line_addr[i] + 1, 9);  // 获取PCoffset9
            }
            // JMP, JSRR
            else if (line[0] == "JMP" || line[0] == "JSRR") {
                machine_code += get_register(line[1]);  // BaseR
                machine_code += "000000";
            }
            // JSR
            else if (line[0] == "JSR") {
                machine_code += get_pc_offset(line[1], line_addr[i] + 1, 11);
            }
            // LD, LDI, ST, STI
            else if (line[0] == "LD" || line[0] == "LDI" || line[0] == "ST" || line[0] == "STI") {
                machine_code += get_register(line[1]);                        // DR
                machine_code += get_pc_offset(line[2], line_addr[i] + 1, 9);  // 获取PCoffset9
            }
            // LDR, STR
            else if (line[0] == "LDR" || line[0] == "STR") {
                machine_code += get_register(line[1]);      // DR
                machine_code += get_register(line[2]);      // BaseR
                machine_code += get_immediate(line[3], 6);  // offset6
            }
            // LEA
            else if (line[0] == "LEA") {
                machine_code += get_register(line[1]);                        // DR
                machine_code += get_pc_offset(line[2], line_addr[i] + 1, 9);  // 获取PCoffset9
            }
            // NOT
            else if (line[0] == "NOT") {
                machine_code += get_register(line[1]);  // DR
                machine_code += get_register(line[2]);  // SR
                machine_code += "111111";
            }
            // RET, RTI: do nothing
            // TRAP
            else if (line[0] == "TRAP") {
                machine_code += get_immediate(line[1], 8);
            }
            output_lines.emplace_back(machine_code);
        }
    }

    return output_lines;
}

bool is_command(const std::string& str) {
    // @param str: 待判断的字符串
    // @return: str是否为指令(包括支持的伪指令)
    return commands.find(str) != commands.end();
}

int get_immediate_value(const std::string& str) {
    // @param str: 立即数字符串, 以'#'或'x'开头
    // @return 立即数的十进制表示
    if (str[0] == '#') {  // 十进制
        return std::stoi(str.substr(1));
    } else {  // 十六进制
        return std::stoi(str.substr(1), nullptr, 16);
    }
}

std::string get_register(const std::string& str) {
    // @param str: 寄存器字符串, 以'R'开头
    // @return 寄存器的二进制字符串
    return std::bitset<3>(str[1] - '0').to_string();
}

std::string get_immediate(const std::string& str, int num_bits) {
    // @param str: 立即数字符串, 以'#'或'x'开头
    // @param num_bits: 立即数的位数
    // @return 立即数的二进制字符串
    switch (num_bits) {
        case 5:
            return std::bitset<5>(get_immediate_value(str)).to_string();
        case 6:
            return std::bitset<6>(get_immediate_value(str)).to_string();
        case 8:
            return std::bitset<8>(get_immediate_value(str)).to_string();
        case 16:
            return std::bitset<16>(get_immediate_value(str)).to_string();
        default:
            std::cerr << "Invalid num_bits!" << std::endl;
            exit(1);
    }
}

std::string get_pc_offset(const std::string& str, const int curr_pc, const int num_bits) {
    // @param str: PCoffset的汇编代码
    // @param curr_pc: 当前PC值
    // @num_bits: PCoffset的位数
    // @return PCoffset的二进制字符串

    int offset;                                          // 偏移量
    if (symbol_table.find(str) == symbol_table.end()) {  // PCoffset是立即数
        offset = get_immediate_value(str);
    } else {  // PCoffset是标签
        offset = symbol_table[str] - curr_pc;
    }
    // 根据PCoffset的位数返回结果
    switch (num_bits) {
        case 9:
            return std::bitset<9>(offset).to_string();
        case 11:
            return std::bitset<11>(offset).to_string();
        default:
            std::cerr << "Invalid num_bits!" << std::endl;
            exit(1);
    }
}