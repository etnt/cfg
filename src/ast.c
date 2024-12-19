#include "ast.h"
#include <stdlib.h>

AstNode* create_number_node(int value) {
    AstNode* node = (AstNode*)malloc(sizeof(AstNode));
    node->type = NODE_NUMBER;
    node->data.number_value = value;
    return node;
}

AstNode* create_binary_node(OpType op, AstNode* left, AstNode* right) {
    AstNode* node = (AstNode*)malloc(sizeof(AstNode));
    node->type = NODE_BINARY_OP;
    node->data.binary.op = op;
    node->data.binary.left = left;
    node->data.binary.right = right;
    return node;
}

void free_ast(AstNode* node) {
    if (node == NULL) return;
    
    if (node->type == NODE_BINARY_OP) {
        free_ast(node->data.binary.left);
        free_ast(node->data.binary.right);
    }
    
    free(node);
}
