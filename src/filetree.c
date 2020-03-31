#include "filetree.h"

#include <glib.h>
#include <gmodule.h>

#include "global.h"
#include "util.h"

#define _GNU_SOURCE

#include <errno.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>

GNode* nary_file_tree;
int current_tree_level;

void filetree_init(char* project_path) {
    char* root_dir = string_append(project_path, "/");
    nary_file_tree = g_node_new(root_dir);
    current_tree_level = 1;
}

void filetree_insert(char* entry, int level) {
    if ((level - current_tree_level) == 1) {
        nary_file_tree = g_node_last_child(nary_file_tree);
    }

    if ((level - current_tree_level) > 1) {
        fprintf(stderr, "ERROR ON TEMPLATE TREE\n");
        exit(1);
    }

    if ((level - current_tree_level) < 0) {
        int j = level;
        while ((j - current_tree_level) != 0 &&
               nary_file_tree->parent != NULL) {
            nary_file_tree = nary_file_tree->parent;
            j++;
        }
    }

    g_node_append_data(nary_file_tree, entry);

    current_tree_level = level;
}

int is_directory(const char* entry) { return get_last_char(entry) == '/'; }

char* get_full_path(GNode* node) {
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
    g_node_traverse(nary_file_tree, G_PRE_ORDER, G_TRAVERSE_ALL, -1,
                    create_filetree_entry, NULL);
}