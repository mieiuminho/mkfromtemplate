#include "metadata.h"

#define _GNU_SOURCE

#include <glib.h>
#include <gmodule.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "util.h"

// static char *filtered_template_path;
// static FILE *filtered_template;
static GHashTable *hash_table_metadata;

void metadata_init(char *project_name) {
    // filtered_template_path = "/tmp/.filtered_template";
    // filtered_template = fopen(filtered_template_path, "w");

    if (hash_table_metadata == NULL) {
        hash_table_metadata = g_hash_table_new(g_str_hash, g_str_equal);
    }

    g_hash_table_insert(hash_table_metadata, "name", strdup(project_name));
}

void metadata_add(const char *variable, const char *value) {
    g_hash_table_insert(hash_table_metadata, strdup(variable), strdup(value));
}

char *metadata_get(const char *variable) {
    return g_hash_table_lookup(hash_table_metadata, variable);
}

static void metadata_replace_value_in_template(char *variable, char *value,
                                               gpointer template) {
    char *markup_variable;
    asprintf(&markup_variable, "{%%%s%%}", variable);
    find_and_replace_in_file(markup_variable, value, template);
}

void metadata_replace_values_in_template(const char *template) {
    g_hash_table_foreach(hash_table_metadata,
                         (GHFunc)metadata_replace_value_in_template,
                         (gpointer) template);
}

// char *metadata_get_filtered_template_path() { return filtered_template_path;
// }
