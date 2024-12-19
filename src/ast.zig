// Node types matching C enum
pub const NodeType = enum(c_int) {
    NODE_NUMBER,
    NODE_BINARY_OP,
};

// Operation types matching C enum
pub const OpType = enum(c_int) {
    OP_ADD,
    OP_SUB,
    OP_MUL,
    OP_DIV,
};

// Binary operation data matching C struct
pub const BinaryData = extern struct {
    op: OpType,
    left: ?*AstNode,
    right: ?*AstNode,
};

// Union data matching C union
pub const NodeData = extern union {
    number_value: c_int,
    binary: BinaryData,
};

// AST node matching C struct
pub const AstNode = extern struct {
    type: NodeType,
    data: NodeData,
};

// Declare the external C functions
pub extern fn parse_expression(input: [*:0]const u8) ?*AstNode;
pub extern fn free_ast(node: ?*AstNode) void;

// Evaluate an AST node
pub fn evaluate(node: ?*AstNode) !i32 {
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
