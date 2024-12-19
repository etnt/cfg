%option noyywrap

%{
#include "parser.tab.h"
#include <stdlib.h>
%}

%%

[0-9]+      { yylval.intval = atoi(yytext); return NUMBER; }
"("         { return LPAREN; }
")"         { return RPAREN; }
"+"         { return PLUS; }
"-"         { return MINUS; }
"*"         { return STAR; }
"/"         { return SLASH; }
[ \t\n]+    ;  // Skip whitespace
.           { printf("Unknown character: %s\n", yytext); }

%%
