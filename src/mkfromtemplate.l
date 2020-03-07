%option noyywrap
%{

%}

%%

A(.)*   printf("%s\n", yytext);

\n          ;

.           ;

%%

int main(int argc, const char** argv) {

    yylex();
    yylex_destroy();

    return 0;
}