const std = @import("std");

// Declare the external C function
extern fn parse_expression(input: [*:0]const u8) c_int;

pub fn main() !void {
    const input = "3 + (4 * 2)";

    const result = parse_expression(input);

    std.debug.print("Result: {}\n", .{result});
}
