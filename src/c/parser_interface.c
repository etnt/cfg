#include "parser.tab.h"
#include "ast.h"
#include <stdio.h>

// Declare flex/bison functions we need
extern int yyparse(void);
extern struct yy_buffer_state* yy_scan_string(const char*);
extern void yy_delete_buffer(struct yy_buffer_state*);

// Declare the AST root from parser
extern AstNode* ast_root;

// Interface function for Zig to call
AstNode* parse_expression(const char *input) {
    struct yy_buffer_state* buffer = yy_scan_string(input);
    ast_root = NULL;
    yyparse();
    yy_delete_buffer(buffer);
    return ast_root;
}
