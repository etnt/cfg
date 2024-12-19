%{
#include <stdio.h>
#include <stdlib.h>
#include "ast.h"

/* Declare functions */
int yylex(void);
void yyerror(const char *s);

/* Root of the AST */
AstNode* ast_root = NULL;
%}

/* Declare tokens */
%token PLUS MINUS STAR SLASH LPAREN RPAREN
%token <intval> NUMBER

/* Define precedence and associativity */
%left PLUS MINUS
%left STAR SLASH

/* Declare value types */
%union {
    int intval;
    struct AstNode* node;
}

/* Declare types for non-terminals */
%type <node> expr term factor

%%

input  : expr    { ast_root = $1; }
       ;

expr   : term                    { $$ = $1; }
       | expr PLUS term          { $$ = create_binary_node(OP_ADD, $1, $3); }
       | expr MINUS term         { $$ = create_binary_node(OP_SUB, $1, $3); }
       ;

term   : factor                  { $$ = $1; }
       | term STAR factor        { $$ = create_binary_node(OP_MUL, $1, $3); }
       | term SLASH factor       { $$ = create_binary_node(OP_DIV, $1, $3); }
       ;

factor : NUMBER                  { $$ = create_number_node($1); }
       | LPAREN expr RPAREN      { $$ = $2; }
       ;

%%

/* Provide error handling */
void yyerror(const char *s) {
    fprintf(stderr, "Error: %s\n", s);
}
