const std = @import("std");

// Node types matching C enum
const NodeType = enum(c_int) {
    NODE_NUMBER,
    NODE_BINARY_OP,
};

// Operation types matching C enum
const OpType = enum(c_int) {
    OP_ADD,
    OP_SUB,
    OP_MUL,
    OP_DIV,
};

// Binary operation data matching C struct
const BinaryData = extern struct {
    op: OpType,
    left: ?*AstNode,
    right: ?*AstNode,
};

// Union data matching C union
const NodeData = extern union {
    number_value: c_int,
    binary: BinaryData,
};

// AST node matching C struct
const AstNode = extern struct {
    type: NodeType,
    data: NodeData,
};

// Declare the external C functions
extern fn parse_expression(input: [*:0]const u8) ?*AstNode;
extern fn free_ast(node: ?*AstNode) void;

// Evaluate an AST node
fn evaluate(node: ?*AstNode) !i32 {
    const n = node orelse return error.NullNode;

    return switch (n.type) {
        .NODE_NUMBER => n.data.number_value,
        .NODE_BINARY_OP => {
            const left = try evaluate(n.data.binary.left);
            const right = try evaluate(n.data.binary.right);

            return switch (n.data.binary.op) {
                .OP_ADD => left + right,
                .OP_SUB => left - right,
                .OP_MUL => left * right,
                .OP_DIV => if (right == 0) error.DivisionByZero else @divTrunc(left, right),
            };
        },
    };
}

pub fn main() !void {
    const input = "3 + (4 * 2)";

    // Parse the expression and get AST
    const ast = parse_expression(input);
    defer free_ast(ast); // Ensure we free the AST

    // Evaluate the AST
    const result = try evaluate(ast);

    // Print both the result and the input
    std.debug.print("Expression: {s}\nResult: {}\n", .{ input, result });
}
