#include <argp.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include "content.h"
#include "filetree.h"
#include "global.h"
#include "metadata.h"
#include "util.h"

extern int metalex();
extern int treelex();
extern int contentlex();

const char *argp_program_version = "mkfromtemplate 0.1.0";

/* Program documentation. */
static char doc[] =
    "mkfromtemplate -- a program to do the initial setup of projects from "
    "templates";

/* A description of the arguments we accept. */
static char args_doc[] = "<PROJECT NAME>";

/* The options we understand. */
static struct argp_option options[] = {
    {"template", 't', "<FILE>", 0, "The template file to use parse", 0},
    {"output", 'o', "<OUTPUT_DIR>", 0, "Where should the project be created",
     0},
    {0}};

/* Used by main to communicate with parse_opt. */
struct arguments {
    char *project_name;
    char *template_file;
    char *output_dir;
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

        case 'o':
            arguments->output_dir = arg;
            break;

        case ARGP_KEY_ARG:
            if (state->arg_num >= 1) {
                /* Too many arguments. */
                argp_usage(state);
            }
            arguments->project_name = arg;
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
static struct argp argp = {options, parse_opt, args_doc, doc, NULL, NULL, NULL};

int main(int argc, char *argv[]) {
    struct arguments arguments;

    /* default values */
    arguments.template_file = "templates/flex.tmpl";
    arguments.output_dir = NULL;

    argp_parse(&argp, argc, argv, 0, 0, &arguments);

    char *tmp_template_file = "/tmp/.mkfrom.tmpl";
    copy_file_to(arguments.template_file, tmp_template_file);

    metadata_init(arguments.project_name);
    dup2(open(tmp_template_file, O_RDONLY), 0);
    metalex();
    metadata_replace_values_in_template(tmp_template_file);

    if (arguments.output_dir == NULL) {
        arguments.output_dir = strdup(arguments.project_name);
    }

    filetree_init(arguments.output_dir);
    dup2(open(tmp_template_file, O_RDONLY), 0);
    treelex();
    create_filetree();

    content_init(arguments.output_dir);
    dup2(open(tmp_template_file, O_RDONLY), 0);
    contentlex();

    return 0;
}
