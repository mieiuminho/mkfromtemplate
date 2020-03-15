#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>

void create_directory(const char* pathname) {
    if (mkdir(pathname, 0777) == -1) {
        fprintf(stderr, "Unable to create directory \"%s\": %s\n", pathname,
                strerror(errno));
        exit(1);
    }
}

/* Prepends text into string. Assumes s has enough space allocated
** for the combined string.
*/
void prepend(char* string, const char* text) {
    size_t len = strlen(text);
    memmove(string + len, string, strlen(string) + 1);
    memcpy(string, text, len);
}

void find_and_replace_in_file(char* variable, char* value, char* file_path) {
    char command[256];

    snprintf(command, sizeof(command), "sed -i 's/%s/%s/g' %s", variable, value,
             file_path);

    system(command);
}

char* trim_whitespace(char* text) {
    int i = 0;
    int f = strlen(text);

    // trim inicial white space
    while (text[i] == ' ' || text[i] == '\t') i++;

    // trim final white space
    while (text[f - 1] == ' ' || text[f - 1] == '\t' || text[f - 1] == '\n')
        f--;
    text[f] = '\0';

    return strdup(text + i);
}
