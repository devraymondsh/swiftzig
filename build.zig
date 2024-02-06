const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const swift_lib_module = b.createModule(.{
        .root_source_file = .{ .path = "src/root.zig" },
    });
    try b.modules.put(b.dupe("swift_lib"), swift_lib_module);

    const tests_step = b.step("test", "Runs all the tests");
    const heap_tests = b.addTest(.{
        .target = target,
        .optimize = optimize,
        .name = "heap_tests",
        .root_source_file = .{ .path = "tests/heap.zig" },
    });
    heap_tests.root_module.addImport("swift_lib", swift_lib_module);
    tests_step.dependOn(&b.addInstallArtifact(heap_tests, .{}).step);
    tests_step.dependOn(&b.addRunArtifact(heap_tests).step);
}
