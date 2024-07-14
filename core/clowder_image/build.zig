const std = @import("std");

const clw_math = @import("../clowder_math/build.zig");

var module: ?*std.Build.Module = null;

inline fn thisPath() []const u8 {
    return comptime std.fs.path.dirname(@src().file) orelse ".";
}

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const lib = b.addStaticLibrary(.{
        .name = "clowder_image",
        .root_source_file = .{ .cwd_relative = "src/root.zig" },
        .target = target,
        .optimize = optimize,
    });

    _ = link(b, lib);

    b.installArtifact(lib);

    const tests = b.addTest(.{
        .root_source_file = .{ .cwd_relative = "src/root.zig" },
        .target = target,
        .optimize = optimize,
    });

    const run_tests = b.addRunArtifact(tests);

    const test_step = b.step("test", "Run tests");
    test_step.dependOn(&run_tests.step);
}

pub fn link(b: *std.Build, step: *std.Build.Step.Compile) *std.Build.Module {
    if (module) |m| {
        return m;
    }

    module = b.createModule(.{
        .root_source_file = .{ .cwd_relative = thisPath() ++ "/src/root.zig" },
        .imports = &.{
            .{
                .name = "clowder_math",
                .module = clw_math.link(b, step),
            },
        },
    });

    const module_ = module.?;

    return module_;
}
