#ifndef __UTIL_H__
#define __UTIL_H__

void find_and_replace_in_file(char* variable, char* value, char* file_path);

char* trim_whitespace(char* text);

void print_separator();

void print_title(const char* title);

#endif