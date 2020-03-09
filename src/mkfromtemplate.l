%option noyywrap

%{
#include <ctype.h>
#include <fcntl.h>
#include <getopt.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

#include "global.h"

#include "metadata.h"
#include "file_tree_util.h"
%}

%%

%%

int parse_arguments(int argc, char** argv) {
    int opt;

    opterr = 0;

    while ((opt = getopt(argc, argv, "t:")) != -1) switch (opt) {
            case 't':
                template_file = optarg;
                break;
            case '?':
                if (optopt == 't')
                    fprintf(stderr, "Option -%c requires an argument.\n",
                            optopt);
                else if (isprint(optopt))
                    fprintf(stderr, "Unknown option `-%c'.\n", optopt);
                else
                    fprintf(stderr, "Unknown option character `\\x%x'.\n",
                            optopt);
                return 1;
            default:
                abort();
        }

    if (optind < argc) project_name = argv[optind++];

    for (; optind < argc; optind++)
        printf("Non-option argument %s\n", argv[optind]);

    return 0;
}

int main(int argc, char** argv) {
    /* defaults */
    template_file = "templates/flex.tmpl";
    project_name = "flexample";

    if (parse_arguments(argc, argv) != 0) {
        return 1;
    }

    printf("##################\n");

    metadata_init(project_name);
    file_tree_init(project_name);

    dup2(open(template_file, O_RDONLY), 0);
    metalex();
    printf("<inicio>%s<fim>\n", metadata_get("email"));
    printf("<inicio>%s<fim>\n", metadata_get("author"));

    dup2(open(filtered_template_path, O_RDONLY), 0);
    treelex();

    printf("Fim do programa!\n");

    return 0;
}
