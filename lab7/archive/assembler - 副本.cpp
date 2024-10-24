#include <iostream>
#include <fstream>
#include <string>
#include <vector>
#include <map>

std::vector<std::string> read_asm_file(const std::string &filename);
void write_output_file(const std::string &filename, const std::vector<std::string> &output);
std::vector<std::string> assemble(const std::vector<std::string> &input_lines);
std::string translate_instruction(const std::string &instruction);

// TODO: Define any additional functions you need to implement the assembler, e.g. the symbol table.

int main(int argc, char *argv[])
{
    // Command-line argument parsing
    if (argc != 3)
    {
        std::cerr << "Usage: " << argv[0] << " <input_file.asm> <output_file.txt>" << std::endl;
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

std::vector<std::string> read_asm_file(const std::string &filename)
{
    std::vector<std::string> lines;
    std::string line;
    std::ifstream file(filename);

    if (file.is_open())
    {
        while (getline(file, line))
        {
            lines.push_back(line);
        }
        file.close();
    }
    else
    {
        std::cerr << "Unable to open file: " << filename << std::endl;
    }

    return lines;
}

void write_output_file(const std::string &filename, const std::vector<std::string> &output)
{
    std::ofstream file(filename);
    if (file.is_open())
    {
        for (const auto &line : output)
        {
            file << line << std::endl;
        }
        file.close();
    }
    else
    {
        std::cerr << "Unable to open file: " << filename << std::endl;
    }
}

std::vector<std::string> assemble(const std::vector<std::string> &input_lines)
{
    std::vector<std::string> output_lines;

    // TODO: Implement the assembly process
    // Implement the 2-pass process described in textbook.

    return output_lines;
}

std::string translate_instruction(const std::string &instruction)
{
    std::string machine_code;

    // TODO: Implement the translation of an individual instruction
    //       to machine code.

    return machine_code;
}
