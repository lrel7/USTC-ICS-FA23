        // .ORIG
        if (line[0] == ".ORIG") {
            output_lines.emplace_back(get_immediate(line[1], 16));  // 将起始地址转化为二进制字符串
        }
        // .FILL
        else if (line[0] == ".FILL") {
            if (symbol_table.find(line[1]) == symbol_table.end()) {                             // 参数是立即数
                output_lines.emplace_back(get_immediate(line[1], 16));                          // 填充二进制字符串
            } else {                                                                            // 参数是符号
                output_lines.emplace_back(std::bitset<16>(symbol_table[line[1]]).to_string());  // 填充符号对应的地址
            }
        }
        // .STRINGZ
        else if (line[0] == ".STRINGZ") {
            for (auto c : line[1]) {
                output_lines.emplace_back(std::bitset<16>(c).to_string());  // 填充字符的ASCII码
            }
            output_lines.emplace_back(16, '0');  // 填充'\0'
        }
        // .BLKW
        else if (line[0] == ".BLKW") {
            for (int j = line_addr[i]; j < line_addr[i + 1]; j++) {
                output_lines.emplace_back(16, '0');  // 填充全0
            }
        }