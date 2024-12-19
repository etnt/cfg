const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Create the executable
    const exe = b.addExecutable(.{
        .name = "cfg",
        .root_source_file = .{ .cwd_relative = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });

    // Run bison to generate parser
    const bison_step = b.addSystemCommand(&[_][]const u8{
        "/bin/sh",
        "-c",
        "cd src/c && bison -d parser.y && mv parser.tab.c parser.c",
    });

    // Run flex to generate lexer
    const flex_step = b.addSystemCommand(&[_][]const u8{
        "/bin/sh",
        "-c",
        "cd src/c && flex -o lexer.c lexer.l",
    });

    // Make flex depend on bison (since lexer needs parser.tab.h)
    flex_step.step.dependOn(&bison_step.step);

    // Add C files
    const c_flags = [_][]const u8{
        "-Wall",
        "-Wextra",
        "-O2",
        "-I.",
        "-Isrc/c",
    };

    exe.addCSourceFile(.{
        .file = .{ .cwd_relative = "src/c/parser.c" },
        .flags = &c_flags,
    });
    exe.addCSourceFile(.{
        .file = .{ .cwd_relative = "src/c/lexer.c" },
        .flags = &c_flags,
    });
    exe.addCSourceFile(.{
        .file = .{ .cwd_relative = "src/c/ast.c" },
        .flags = &c_flags,
    });
    exe.addCSourceFile(.{
        .file = .{ .cwd_relative = "src/c/parser_interface.c" },
        .flags = &c_flags,
    });

    // Link with libc
    exe.linkLibC();

    // Make exe depend on generated files
    exe.step.dependOn(&flex_step.step);

    // Install the executable
    b.installArtifact(exe);

    // Create run step
    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    // Add clean step
    const clean_step = b.addSystemCommand(&[_][]const u8{
        "/bin/sh",
        "-c",
        "rm -f src/c/parser.c src/c/parser.tab.h src/c/lexer.c",
    });

    const clean = b.step("clean", "Clean generated files");
    clean.dependOn(&clean_step.step);

    // Add test step
    const exe_unit_tests = b.addTest(.{
        .root_source_file = .{ .cwd_relative = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });

    const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_exe_unit_tests.step);
}
