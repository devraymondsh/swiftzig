const std = @import("std");

pub fn add_tests(
    b: *std.Build,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
    swift_lib: *std.Build.Module,
    tests_step: *std.Build.Step,
    comptime tests: anytype,
    comptime exe_tests: anytype,
) void {
    inline for (tests) |name| {
        const new_tests = b.addTest(.{
            .target = target,
            .optimize = optimize,
            .name = std.fmt.comptimePrint("{s}_tests", .{name}),
            .root_source_file = .{ .path = std.fmt.comptimePrint("tests/{s}.zig", .{name}) },
        });
        new_tests.root_module.addImport("swift_lib", swift_lib);
        tests_step.dependOn(&b.addRunArtifact(new_tests).step);
        tests_step.dependOn(&b.addInstallArtifact(new_tests, .{}).step);
    }
    inline for (exe_tests) |name| {
        const new_tests = b.addExecutable(.{
            .target = target,
            .optimize = optimize,
            .name = std.fmt.comptimePrint("{s}_tests", .{name}),
            .root_source_file = .{ .path = std.fmt.comptimePrint("tests/{s}.zig", .{name}) },
        });
        new_tests.root_module.addImport("swift_lib", swift_lib);
        tests_step.dependOn(&b.addRunArtifact(new_tests).step);
        tests_step.dependOn(&b.addInstallArtifact(new_tests, .{}).step);
    }
}

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const swift_lib = b.createModule(.{
        .root_source_file = .{ .path = "src/root.zig" },
    });
    try b.modules.put(b.dupe("swift_lib"), swift_lib);

    const tests_step = b.step("test", "Runs all the tests");
    add_tests(
        b,
        target,
        optimize,
        swift_lib,
        tests_step,
        .{ "heap", "math" },
        .{
            "start0-u8",
            "start0-void",
            "start1-u8",
            "start1-void",
            "start2-u8",
            "start2-void",
        },
    );
}
