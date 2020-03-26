#ifndef __METADATA_H__
#define __METADATA_H__

void metadata_init(char *project_name);

void metadata_add(char *text);

char *metadata_get(const char *variable);

void metadata_replace_values_in_template(const char *template);

#endif
