#ifndef __FILETREEE_H__
#define __FILETREEE_H__

/**
 * @brief Initializes the necessary structures for storing the project's
 * directory tree.
 *
 * @param project_path  The path for the root directory.
 */
void filetree_init(char* project_path);

void filetree_insert(char* entry, int level);

void create_filetree();

#endif
