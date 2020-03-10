%option noyywrap prefix="tree"

%{
#include <glib.h>
#include <gmodule.h>

#include "file_tree.h"

#include "global.h"
#include "util.h"

GNode* nary_file_tree;
int current_tree_level;

void debug_info_file_tree();
%}

%s TREE

d               [0-9]
ws              [ \t]*
qname           [a-zA-Z][a-zA-Z0-9_\-]*
filename        [a-zA-Z0-9][a-zA-Z0-9_\-\.]*
SEPARATOR       ^{ws}==={ws}

%%

                                    BEGIN 0;

{SEPARATOR}tree                     BEGIN TREE;

<TREE>[-]+{ws}{filename}[/]?{ws}    {
    /* Remove dash and spaces (-) from string */
    int i = 0;
    while(i < yyleng) {
        if (yytext[i] != '-') break;
        i++;
    }
    char* entry = trim_whitespace(yytext + i);

    if ((i - current_tree_level) > 1) {
        printf("ERROR ON TEMPLATE TREE\n");
        printf("ERROR ON LINE: %s", yytext);
        exit(1);
    }

    if((i - current_tree_level) <= -1) {
        while((i - current_tree_level) != 0 && nary_file_tree->parent != NULL) {
            nary_file_tree = nary_file_tree->parent;
            i++;
        }
    }

    if ((i - current_tree_level) == 1) {
        nary_file_tree = g_node_last_child(nary_file_tree);
    }

    g_node_append_data(nary_file_tree, entry);

    current_tree_level = i;
}

<TREE>{SEPARATOR}{qname}            {
    debug_info_file_tree();
     yyterminate();
}

[ \t\n\r]                           ;

(.)*                                ;

%%

void file_tree_init(char* project) {
    char* dir = strdup(project);
    realloc(dir, strlen(project) + 2);
    strcat(dir, "/");
    nary_file_tree = g_node_new(dir);
    current_tree_level = 1;
}

int isDirectory(char* entry) {
    return entry[strlen(entry) - 1] == '/';
}

gboolean showTreeEntry(GNode *node, gpointer data) {
    if(G_NODE_IS_ROOT(node)) {
        printf("ROOT: <>%s<>\n", (char*) node->data);
    } else if (isDirectory(node->data)) {
        printf("Directory: <>%s<>\n", (char*) node->data);
    } else {
        printf("File: <>%s<>\n", (char*) node->data);
    }
    return FALSE;
}

void debug_info_file_tree() {
    g_node_traverse(
        nary_file_tree,
        G_PRE_ORDER,
        G_TRAVERSE_ALL,
        -1,
        showTreeEntry,
        NULL
    );
    print_separator();
}
