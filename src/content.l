%option noyywrap prefix="content"

%{
#include <stdio.h>
#include <stdlib.h>

#include "global.h"
#include "util.h"

FILE* current_file = NULL;
%}

d               [0-9]
ws              [ \t]*
full_filename   [a-zA-Z0-9][a-zA-Z0-9_\-\./]*
SEPARATOR       ^{ws}==={ws}

%s INSIDE_FILE

%%

                                    BEGIN 0;
{SEPARATOR}tree{ws}                 BEGIN 0;
{SEPARATOR}meta{ws}                 BEGIN 0;

{SEPARATOR}{full_filename}{ws}\n    {
    BEGIN INSIDE_FILE;
    char* file_path;

    if(current_file != NULL) {
        fclose(current_file);
    }

    file_path = trim_whitespace(yytext);
    file_path = file_path + 3;
    file_path = trim_whitespace(file_path);
    file_path = realloc(file_path, strlen(file_path) + 32);

    char* dir = strdup(project_name);
    realloc(dir, strlen(project_name) + 2);
    strcat(dir, "/");

    prepend(file_path, dir);
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
