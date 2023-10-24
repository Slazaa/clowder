const std = @import("std");

const CompileStep = std.Build.Step.Compile;
const Module = std.Build.Module;

fn thisPath(comptime suffix: []const u8) []const u8 {
    return comptime (std.fs.path.dirname(@src().file) orelse ".") ++ suffix;
}

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const lib = b.addStaticLibrary(.{
        .name = "clowder_ecs",
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });

    link(b, lib);

    b.installArtifact(lib);

    const main_tests = b.addTest(.{
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });

    const run_main_tests = b.addRunArtifact(main_tests);

    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&run_main_tests.step);
}
pub fn link(b: *std.Build, step: *CompileStep) *Module {
    step.linkLibC();

    const module = b.createModule(.{
        .source_file = .{ .path = thisPath("/src/main.zig") },
    });

    step.addModule("clowder_ecs", module);

    return module;
}
