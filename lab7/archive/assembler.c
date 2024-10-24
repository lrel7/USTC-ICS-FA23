#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_LINE_LENGTH 100

// Function prototypes
void read_asm_file(const char *filename, char lines[][MAX_LINE_LENGTH], int *num_lines);
void write_output_file(const char *filename, const char *output[], int num_lines);
void assemble(char lines[][MAX_LINE_LENGTH], int num_lines, char *output[]);
void translate_instruction(const char *instruction, char *machine_code);

// TODO: Define any additional functions you need to implement the assembler, e.g. the symbol table.

int main(int argc, char *argv[])
{
    // Command-line argument parsing
    if (argc != 3)
    {
        fprintf(stderr, "Usage: %s <input_file.asm> <output_file.txt>\n", argv[0]);
        return 1;
    }

    char input_filename[100];
    char output_filename[100];
    strcpy(input_filename, argv[1]);
    strcpy(output_filename, argv[2]);

    char lines[100][MAX_LINE_LENGTH]; // Assuming a maximum of 100 lines
    int num_lines = 0;
    read_asm_file(input_filename, lines, &num_lines);

    char *output[100]; // Output array of strings
    for (int i = 0; i < 100; i++)
    {
        output[i] = (char *)malloc(MAX_LINE_LENGTH * sizeof(char));
    }

    assemble(lines, num_lines, output);
    write_output_file(output_filename, (const char **)output, num_lines);

    // Free allocated memory
    for (int i = 0; i < 100; i++)
    {
        free(output[i]);
    }

    return 0;
}

void read_asm_file(const char *filename, char lines[][MAX_LINE_LENGTH], int *num_lines)
{
    FILE *file = fopen(filename, "r");
    if (file == NULL)
    {
        fprintf(stderr, "Unable to open file: %s\n", filename);
        exit(1);
    }

    char line[MAX_LINE_LENGTH];
    while (fgets(line, MAX_LINE_LENGTH, file))
    {
        strcpy(lines[*num_lines], line);
        (*num_lines)++;
    }

    fclose(file);
}

void write_output_file(const char *filename, const char *output[], int num_lines)
{
    FILE *file = fopen(filename, "w");
    if (file == NULL)
    {
        fprintf(stderr, "Unable to open file: %s\n", filename);
        exit(1);
    }

    for (int i = 0; i < num_lines; i++)
    {
        fprintf(file, "%s\n", output[i]);
    }

    fclose(file);
}

void assemble(char lines[][MAX_LINE_LENGTH], int num_lines, char *output[])
{
    // TODO: Implement the assembly process
    // Implement the 2-pass process described in textbook.

    for (int i = 0; i < num_lines; i++)
    {
        translate_instruction(lines[i], output[i]);
    }
}

void translate_instruction(const char *instruction, char *machine_code)
{
    // TODO: Implement the translation of an individual instruction
    //       to machine code.
}
