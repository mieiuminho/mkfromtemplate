#ifndef __UTIL_H__
#define __UTIL_H__

void create_directory(const char* pathname);

void prepend(char* string, const char* text);

void find_and_replace_in_file(char* variable, char* value, char* file_path);

char* trim_whitespace(char* text);

#endif