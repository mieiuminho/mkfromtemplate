%option noyywrap prefix="tree"

%{
#include "filetree.h"

#include <glib.h>
#include <gmodule.h>

#include "global.h"
#include "util.h"

GNode* nary_file_tree;
int current_tree_level;

int filetree_insert(char* entry, int level);
void create_filetree();
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
    /* Remove dashs and spaces from string */
    int i = 0;
    while(i < yyleng) {
        if (yytext[i] != '-') break;
        i++;
    }
    char* entry = trim_whitespace(yytext + i);

    current_tree_level = filetree_insert(entry, i);
}

<TREE>{SEPARATOR}{qname}            {
    create_filetree();
    yyterminate();
}

[ \t\n\r]                           ;

(.)*                                ;

%%

void filetree_init(char* project) {
    char* dir = strdup(project);
    realloc(dir, strlen(project) + 2);
    strcat(dir, "/");
    nary_file_tree = g_node_new(dir);
    current_tree_level = 1;
}

int filetree_insert(char* entry, int level) {
    if ((level - current_tree_level) == 1) {
        nary_file_tree = g_node_last_child(nary_file_tree);
    }

    if ((level - current_tree_level) > 1) {
        fprintf(stderr, "ERROR ON TEMPLATE TREE\n");
        fprintf(stderr, "ERROR ON LINE: %s", yytext);
        exit(1);
    }

    if((level - current_tree_level) < 0) {
        int j = level;
        while((j - current_tree_level) != 0 && nary_file_tree->parent != NULL) {
            nary_file_tree = nary_file_tree->parent;
            j++;
        }
    }

    g_node_append_data(nary_file_tree, entry);

    return level;
}

int is_directory(char* entry) {
    return entry[strlen(entry) - 1] == '/';
}

char* get_full_path(GNode *node) {
    GNode* pointer = node;

    char* full_path = strdup(pointer->data);

    while (pointer->parent != NULL) {
        pointer = pointer->parent;
        full_path = string_prepend(full_path, pointer->data);
    }

    return full_path;
}

gboolean create_filetree_entry(GNode* node, gpointer data) {

    if (G_NODE_IS_ROOT(node)) {
        create_directory(node->data);
    } else if (is_directory(node->data)) {
        create_directory(get_full_path(node));
    } else {
        fclose(fopen(get_full_path(node), "w"));
    }

    return FALSE;
}

void create_filetree() {
    g_node_traverse(
        nary_file_tree,
        G_PRE_ORDER,
        G_TRAVERSE_ALL,
        -1,
        create_filetree_entry,
        NULL
    );
}
