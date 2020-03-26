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
SEPARATOR       ^{ws}==={ws}

%%

                                    BEGIN 0;

{SEPARATOR}meta                     BEGIN METADATA;

<METADATA>{qname}\:{ws}(.)+         { metadata_add(yytext); }

<METADATA>{SEPARATOR}{qname}        {
    BEGIN 0;
    yyterminate();
}

<METADATA>(.)*|[\n\r]                ;

(.)*|\n                              ;

<<EOF>>     {
    yyterminate();
}
%%
