#include <argp.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

#include "global.h"
#include "util.h"

#include "metadata.h"
#include "filetree.h"

const char *argp_program_version = "mkfromtemplate 0.1.0";

/* Program documentation. */
static char doc[] =
    "mkfromtemplate -- a program to do the initial setup of projects from templates";

/* A description of the arguments we accept. */
static char args_doc[] = "<PROJECT NAME>";

/* The options we understand. */
static struct argp_option options[] = {
  {"template", 't', "FILE",  0, "The template file to use parse"},
  { 0 }
};

/* Used by main to communicate with parse_opt. */
struct arguments {
    char* project;  // name of the project
    char* template_file;
};

/* Parse a single option. */
static error_t parse_opt(int key, char *arg, struct argp_state *state) {
    /* Get the input argument from argp_parse, which we
       know is a pointer to our arguments structure. */
    struct arguments *arguments = state->input;

    switch (key) {
        case 't':
            arguments->template_file = arg;
            break;

        case ARGP_KEY_ARG:
            if (state->arg_num >= 1) {
                /* Too many arguments. */
                argp_usage(state);
            }
            arguments->project = arg;
            break;

        case ARGP_KEY_END:
            if (state->arg_num < 1) {
                /* Not enough arguments. */
                argp_usage(state);
            }
            break;

        default:
            return ARGP_ERR_UNKNOWN;
    }

    return 0;
}

/* Our argp parser. */
static struct argp argp = {options, parse_opt, args_doc, doc};

int main (int argc, char *argv[]) {
  struct arguments arguments;

  /* default values */
  arguments.template_file = "templates/flex.tmpl";

  argp_parse(&argp, argc, argv, 0, 0, &arguments);

  project_name = strdup(arguments.project);
  metadata_init(project_name);
  filetree_init(project_name);

  dup2(open(arguments.template_file, O_RDONLY), 0);
  metalex();

  dup2(open(filtered_template_path, O_RDONLY), 0);
  treelex();

  dup2(open(filtered_template_path, O_RDONLY), 0);
  contentlex();

  return 0;
}
