#include "util.h"

/**
 * @file util.c
 *
 */

#define _GNU_SOURCE

#include <errno.h>
#include <fcntl.h>
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

void copy_file_to(const char* source, const char* dest) {
    int in = open(source, O_RDONLY);
    int out = open(dest, O_CREAT | O_WRONLY | O_TRUNC, 0666);

    if (in == -1 || out == -1) {
        fprintf(stderr, "Unable to create copy of \"%s\": %s\n", source,
                strerror(errno));
        exit(1);
    }

    char buf[8192];
    ssize_t read_size;

    while ((read_size = read(in, buf, sizeof(buf))) != 0) {
        write(out, buf, read_size);
    }
}

/**
 * @brief Prependes pre_text to text
 *
 * @details This function creates a string with enough space for pre_text and
 * pre_text together. If this returned string is not needed anymore it should
 * be deallocated.
 *
 * @param text string to preattach some text
 * @param pre_text what to attach to text
 * @return the result of pre_text + text
 */
char* string_prepend(const char* text, const char* pre_text) {
    size_t pre_text_len = strlen(pre_text);
    size_t text_len = strlen(text);
    char* result = malloc(sizeof(char) * (pre_text_len + text_len + 1));
    memcpy(result, pre_text, pre_text_len);
    memcpy(result + pre_text_len, text, text_len + 1);
    return result;
}

char* string_append(const char* text, const char* pos_text) {
    return string_prepend(pos_text, text);
}

char get_last_char(const char* string) { return string[strlen(string) - 1]; }

void find_and_replace_in_file(char* variable, char* value, char* file_path) {
    char* command;
    asprintf(&command, "sed -i 's/%s/%s/g' %s", variable, value, file_path);
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
