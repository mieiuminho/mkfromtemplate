%option noyywrap prefix="meta"

%{
#include <glib.h>
#include <gmodule.h>

#include "metadata.h"

#include "global.h"
#include "util.h"

GHashTable* hash_table_metadata;
FILE* filtered_template;

void metadata_update_values_in_template(char* variable, char* value, char* file_path);
%}

%x METADATA

d               [0-9]
ws              [ \t]*
qname           [a-zA-Z][a-zA-Z0-9_\-]*
SEPARATOR       ^{ws}==={ws}

%%

                                    BEGIN 0;

{SEPARATOR}meta                     { BEGIN METADATA; }

<METADATA>{qname}\:{ws}(.)+         { metadata_add(yytext); }

<METADATA>{SEPARATOR}{qname}        {
    BEGIN 0;
    fputs(yytext, filtered_template);
}

<METADATA>(.)*|[\n]                 ;

[\n\t\r]    fputs(yytext, filtered_template);

(.)*        fputs(yytext, filtered_template);

<<EOF>>     {
    fclose(filtered_template);
    g_hash_table_foreach(hash_table_metadata, (GHFunc) metadata_update_values_in_template, filtered_template_path);
    yyterminate();
}
%%

void metadata_update_values_in_template(char* variable, char* value, char* file_path) {
    char markup_variable[32];
    snprintf(markup_variable, sizeof(markup_variable), "{%%%s%%}", variable);
    find_and_replace_in_file(markup_variable, value, file_path);
}

void metadata_init(char* project) {
    filtered_template_path = "/tmp/.filtered_template";
    filtered_template = fopen(filtered_template_path,"w");
    if (hash_table_metadata == NULL) {
        hash_table_metadata = g_hash_table_new(g_str_hash, g_str_equal);
    }

    g_hash_table_insert(hash_table_metadata, "name", project);
}

char *trim_whitespace(char *text) {
    int i = 0;
    int f = strlen(text);

    // trim inicial white space
    while (text[i] == ' ' || text[i] == '\t') i++;

    // trim final white space
    while (text[f - 1] == ' ' || text[i] == '\t') f--;
    text[f] = '\0';

    return strdup(text + i);
}

void metadata_add(char *text) {
    char *var_name;
    char *var_value;

    const char separator[2] = ":";
    char *token = strtok(text, separator);

    var_name = strdup(token);

    token = strtok(NULL, separator);

    var_value = trim_whitespace(token);

    g_hash_table_insert(hash_table_metadata, var_name, var_value);
}

char *metadata_get(const char *variable) {
    return g_hash_table_lookup(hash_table_metadata, variable);
}
