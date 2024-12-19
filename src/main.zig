const std = @import("std");
const ast = @import("ast.zig");

pub fn main() !void {
    const input = "3 + (4 * 2)";

    // Parse the expression and get AST
    const tree = ast.parse_expression(input);
    defer ast.free_ast(tree); // Ensure we free the AST

    // Evaluate the AST
    const result = try ast.evaluate(tree);

    // Print both the result and the input
    std.debug.print("Expression: {s}\nResult: {}\n", .{ input, result });
}
