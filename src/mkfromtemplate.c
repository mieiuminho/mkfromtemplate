#include <argp.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include "content.h"
#include "filetree.h"
#include "global.h"
#include "ini.h"
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
    {"config", 'c', "<CONFIG>", 0, "Configuration to read at program start", 0},
    {"template", 't', "<FILE>", 0, "The template file to use parse", 0},
    {"debug", 'd', 0, 0, "Output debug information", 0},
    {"output", 'o', "<OUTPUT_DIR>", 0, "Where should the project be created",
     0},
    {0}};

/* Used by main to communicate with parse_opt. */
struct arguments {
    char *project_name;
    char *configuration_file;
    char *template_file;
    char *output_dir;
    int debug;
};

/* Parse a single argument option. */
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

        case 'c':
            arguments->configuration_file = arg;
            break;

        case 'd':
            arguments->debug = 1;
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

struct configuration {
    const char *templates_path;
    const char *templates_default;
};

/* Parse a single configuration option. */
static int handler(void *configuration, const char *section, const char *name,
                   const char *value) {
    struct configuration *config = (struct configuration *)configuration;

#define MATCH(s, n) strcmp(section, s) == 0 && strcmp(name, n) == 0
    if (MATCH("templates", "path")) {
        config->templates_path = strdup(value);
    } else if (MATCH("templates", "default")) {
        config->templates_default = strdup(value);
    } else {
        /* unknown section/name, error */
        return 0;
    }

    return 1;
}

int main(int argc, char *argv[]) {
    struct arguments arguments;
    struct configuration configuration;

    /* default values */
    char *tmp_template_file = "/tmp/.mkfrom.tmpl";
    arguments.debug = 0;
    arguments.configuration_file =
        expand_path("~/.config/mkfromtemplate/config.ini");
    arguments.template_file = NULL;
    arguments.output_dir = NULL;

    /* Parse command line arguments */
    argp_parse(&argp, argc, argv, 0, 0, &arguments);

    /* Parse configuration file */
    if (ini_parse(arguments.configuration_file, handler, &configuration) < 0) {
        printf("Can't load '%s'\n", arguments.configuration_file);
        return 1;
    }

    if (arguments.debug) {
        printf(
            "Config loaded from '%s': templates.path=%s, "
            "templates.default=%s\n",
            expand_path(arguments.configuration_file),
            expand_path(configuration.templates_path),
            configuration.templates_default);
    }

    /* Define the correct template file to use */
    if (arguments.template_file == NULL) {
        arguments.template_file =
            string_append(expand_path(configuration.templates_path),
                          configuration.templates_default);
    } else if (!file_exists(arguments.template_file)) {
        arguments.template_file = string_prepend(
            arguments.template_file, expand_path(configuration.templates_path));
    }

    /* use projet name for output dir if not stated otherwise */
    if (arguments.output_dir == NULL) {
        arguments.output_dir = strdup(arguments.project_name);
    }

    copy_file_to(arguments.template_file, tmp_template_file);

    metadata_init(arguments.project_name);
    dup2(open(tmp_template_file, O_RDONLY), 0);
    metalex();
    metadata_replace_values_in_template(tmp_template_file);

    filetree_init(arguments.output_dir);
    dup2(open(tmp_template_file, O_RDONLY), 0);
    treelex();
    create_filetree();

    content_init(arguments.output_dir);
    dup2(open(tmp_template_file, O_RDONLY), 0);
    contentlex();

    return 0;
}
