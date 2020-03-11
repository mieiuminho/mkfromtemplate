#ifndef __METADATA_H__
#define __METADATA_H__

void metadata_init(char *project);

void metadata_add(char *text);

char *metadata_get(const char *variable);

#endif
