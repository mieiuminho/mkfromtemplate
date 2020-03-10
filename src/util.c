#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

void find_and_replace_in_file(char* variable, char* value, char* file_path) {
    char command[256];

    snprintf(command, sizeof(command), "sed -i 's/%s/%s/g' %s", variable, value, file_path);

    system(command);
}

char* trim_whitespace(char *text) {
    int i = 0;
    int f = strlen(text);

    // trim inicial white space
    while (text[i] == ' ' || text[i] == '\t') i++;

    // trim final white space
    while (text[f - 1] == ' ' || text[f - 1] == '\t') f--;
    text[f] = '\0';

    return strdup(text + i);
}

void print_separator() {
    puts("====================================================");
}

void print_title(char* title) {
    print_separator();
    puts(title);
    print_separator();
}
