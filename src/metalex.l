%option noyywrap prefix="meta"

%{
#include "metadata.h"

#define _GNU_SOURCE

#include <glib.h>
#include <gmodule.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "global.h"
#include "util.h"

%}

%x METADATA

d               [0-9]
ws              [ \t]*
qname           [a-zA-Z][a-zA-Z0-9_\-]*
filename        [a-zA-Z0-9\._][a-zA-Z0-9_\-\.]*
SEPARATOR       ^{ws}==={ws}

%%

                                    BEGIN 0;

{SEPARATOR}meta{ws}                 BEGIN METADATA;

<METADATA>{qname}\:{ws}(.)+         {
    char *var_name;
    char *var_value;

    const char separator[2] = ":";
    char *token = strtok(yytext, separator);

    var_name = strdup(token);

    token = strtok(NULL, separator);

    var_value = trim_whitespace(token);

    metadata_add(var_name, var_value);
}

<METADATA>{SEPARATOR}{filename}{ws} {
    BEGIN 0;
    yyterminate();
}

<METADATA>(.)*|[\n\r]                ;

(.)*|\n                              ;

<<EOF>>     {
    yyterminate();
}
%%
