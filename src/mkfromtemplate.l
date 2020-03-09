%option noyywrap
%{
char * name;
char * author;
char * email;
%}

%s METADATA
%s TREE

d               [0-9]
ws              [ \t]*
qname           [a-zA-Z][a-zA-Z0-9_\-]*
pname           [a-zA-ZàáâäãåąčćęèéêëėįìíîïłńòóôöõøùúûüųūÿýżźñçčšžÀÁÂÄÃÅĄĆČĖĘÈÉÊËÌÍÎÏĮŁŃÒÓÔÖÕØÙÚÛÜŲŪŸÝŻŹÑßÇŒÆČŠŽ∂ð \,\.\'\-]+
email           [a-zA-Z][a-zA-Z0-9_\-.+]*@[a-zA-Z][a-zA-Z0-9\-.]*[a-z]
SEPARATOR       ^{ws}==={ws}

%%

[ \t\n]                             ;

{SEPARATOR}/meta                    { printf("Entramos em METADATA\n"); BEGIN METADATA; }

<METADATA>email\:{ws}{email}        { email = strdup(yytext + 6); printf("EMAIL: %s\n", email); }
<METADATA>author\:{ws}{pname}       { author = strdup(yytext + 7); printf("AUTHOR: %s\n", author); }

{SEPARATOR}/tree                    { printf("Entramos em TREE\n"); BEGIN TREE; }

<TREE>[-]+(.)*                      { printf("%s\n", yytext); }

{SEPARATOR}{qname}                  { printf("Entramos em outra cena: %s\n", yytext + 4); BEGIN 0; }

<<EOF>>                             { printf("Chegamos ao fim do ficheiro de template!\n"); return 0; }

.|\n ;

%%

int main(int argc, const char** argv) {

    yylex();
    yylex_destroy();

    printf("Fim do programa!\n");

    return 0;
}