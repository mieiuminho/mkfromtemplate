%option noyywrap
%{
char * name;
char * author;
char * email;
%}

%x METADATA

d               [0-9]   // digit
ws              [ \t]*  // white space
qname           [a-zA-Z][a-zA-Z0-9_\-.:]*
SEPARATOR       [=== ]

%%

            // BEGIN 0;

{SEPARATOR}meta     BEGIN METADATA;

<METADATA>email\:   ECHO;

{SEPARATOR}{qname}  BEGIN 0;

<<EOF>>             { printf("Chegamos ao fim do ficheiro de template!\n"); return 0; }

%%

int main(int argc, const char** argv) {

    yylex();
    yylex_destroy();

    return 0;
}