#ifndef AST_H
#define AST_H

// Node types
typedef enum {
    NODE_NUMBER,
    NODE_BINARY_OP
} NodeType;

// Operation types
typedef enum {
    OP_ADD,
    OP_SUB,
    OP_MUL,
    OP_DIV
} OpType;

// AST node structure
typedef struct AstNode {
    NodeType type;
    union {
        // Number node
        int number_value;

        // Binary operation node
        struct {
            OpType op;
            struct AstNode* left;
            struct AstNode* right;
        } binary;
    } data;
} AstNode;

// Function to create nodes
AstNode* create_number_node(int value);
AstNode* create_binary_node(OpType op, AstNode* left, AstNode* right);

// Function to free the AST
void free_ast(AstNode* node);

#endif // AST_H
