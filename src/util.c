#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

void find_and_replace_in_file(char* variable, char* value, char* file_path) {
    char command[256];

    snprintf(command, sizeof(command), "sed -i 's/%s/%s/g' %s", variable, value, file_path);

    system(command);
}
