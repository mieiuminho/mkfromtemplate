#ifndef __UTIL_H__
#define __UTIL_H__

void create_directory(const char* pathname);

void copy_file_to(const char* source, const char* dest);

int file_exists(const char* filename);

char* expand_path(const char* path);

char* string_prepend(const char* text, const char* pre_text);

char* string_append(const char* text, const char* pos_text);

char get_last_char(const char* string);

void find_and_replace_in_file(char* variable, char* value, char* file_path);

char* trim_whitespace(char* text);

#endif