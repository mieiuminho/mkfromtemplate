%option noyywrap prefix="content"

%{
#include "content.h"

#include <stdio.h>
#include <stdlib.h>

#include "global.h"
#include "util.h"

FILE* current_file = NULL;
char* root_dir;
%}

d               [0-9]
ws              [ \t]*
full_filename   [a-zA-Z0-9][a-zA-Z0-9_\-\./]*
SEPARATOR       ^{ws}==={ws}

%s INSIDE_FILE

%%

                                    BEGIN 0;
{SEPARATOR}tree{ws}\n               BEGIN 0;
{SEPARATOR}meta{ws}\n               BEGIN 0;

{SEPARATOR}{full_filename}{ws}\n    {
    BEGIN INSIDE_FILE;
    char* file_path;

    if (current_file != NULL) {
        fclose(current_file);
    }

    file_path = trim_whitespace(trim_whitespace(yytext) + 3);
    file_path = string_prepend(file_path, root_dir);

    current_file = fopen(file_path, "w+");
}

<INSIDE_FILE>(.)*|\n                {
    fprintf(current_file, "%s", yytext);
}

(.)*|\n                             ;

<<EOF>>                             {
    yyterminate();
}

%%

void content_init(const char* project_path) {
    root_dir = strdup(project_path);

    if(get_last_char(root_dir) != '/') {
        root_dir = string_append(root_dir, "/");
    }
}
