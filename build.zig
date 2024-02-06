const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const swift_lib_module = b.createModule(.{
        .root_source_file = .{ .path = "src/root.zig" },
    });
    try b.modules.put(b.dupe("swift_lib"), swift_lib_module);

    const lib = b.addStaticLibrary(.{
        .name = "swift_lib",
        .root_source_file = .{ .path = "src/root.zig" },
        .target = target,
        .optimize = optimize,
    });

    b.installArtifact(lib);
}
