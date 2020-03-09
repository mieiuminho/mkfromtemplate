%option noyywrap prefix="tree"

%{
#include "global.h"
%}

%s TREE

d               [0-9]
ws              [ \t]*
qname           [a-zA-Z][a-zA-Z0-9_\-]*
SEPARATOR       ^{ws}==={ws}

%%

[ \t\n]                             ;

{SEPARATOR}tree                     { printf("Entramos em TREE\n"); BEGIN TREE; }

<TREE>[-]+(.)*                      { printf("%s\n", yytext); }

{SEPARATOR}{qname}                  { printf("Entramos em outra cena: %s\n", yytext + 4); BEGIN 0; }

<<EOF>>                             { printf("Chegamos ao fim do ficheiro de template!\n"); return 0; }

(.)*                                printf("%s\n", yytext);

%%