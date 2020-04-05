%option noyywrap prefix="tree"

%{
#include "filetree.h"

#include <glib.h>
#include <gmodule.h>

#include "global.h"
#include "util.h"

%}

%s TREE

d               [0-9]
ws              [ \t]*
filename        [a-zA-Z0-9\._][a-zA-Z0-9_\-\.]*
SEPARATOR       ^{ws}==={ws}

%%

                                    BEGIN 0;

{SEPARATOR}tree{ws}                 BEGIN TREE;

<TREE>[-]+{ws}{filename}[/]?{ws}    {
    /* Remove dashs and spaces from string */
    int level = 0;
    while(level < yyleng) {
        if (yytext[level] != '-') break;
        level++;
    }
    char* entry = trim_whitespace(yytext + level);

    filetree_insert(entry, level);
}

<TREE>{SEPARATOR}{filename}            {
    yyterminate();
}

[ \t\n\r]                           ;

(.)*                                ;

%%
