%{
#include <stdio.h>
#include <stdlib.h>

/* Declare functions */
int yylex(void);
void yyerror(const char *s);

/* Declare the global result variable */
extern int result;
%}

/* Declare tokens */
%token PLUS MINUS STAR SLASH LPAREN RPAREN

/* Define precedence and associativity */
%left PLUS MINUS
%left STAR SLASH

/* Declare a value type for the tokens (e.g., numbers) */
%union {
    int intval;
}

/* Declare which tokens use the value type */
%type <intval> expr term factor
%token <intval> NUMBER

%%

/* Grammar rules */
input  : expr    { result = $1; }
       ;

expr   : term
       | expr PLUS term   { $$ = $1 + $3; }
       | expr MINUS term  { $$ = $1 - $3; }
       ;

term   : factor
       | term STAR factor { $$ = $1 * $3; }
       | term SLASH factor {
             if ($3 == 0) { fprintf(stderr, "Division by zero\n"); exit(1); }
             $$ = $1 / $3;
         }
       ;

factor : NUMBER
       | LPAREN expr RPAREN { $$ = $2; }
       ;

%%

/* Provide error handling */
void yyerror(const char *s) {
    fprintf(stderr, "Error: %s\n", s);
}
