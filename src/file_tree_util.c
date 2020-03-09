#include <glib.h>
#include <gmodule.h>

GNode* nary_file_tree;

void file_tree_init(char* project) { nary_file_tree = g_node_new(project); }
