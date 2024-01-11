const std = @import("std");

const CompileStep = std.Build.Step.Compile;
const Module = std.Build.Module;

var module: ?*Module = null;

fn thisPath(comptime suffix: []const u8) []const u8 {
    return comptime (std.fs.path.dirname(@src().file) orelse ".") ++ suffix;
}

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const lib = b.addStaticLibrary(.{
        .name = "clowder_ecs",
        .root_source_file = .{ .path = "src/root.zig" },
        .target = target,
        .optimize = optimize,
    });

    _ = link(b, lib);

    b.installArtifact(lib);

    const tests = b.addTest(.{
        .root_source_file = .{ .path = "src/root.zig" },
        .target = target,
        .optimize = optimize,
    });

    const run_tests = b.addRunArtifact(tests);

    const test_step = b.step("test", "Run tests");
    test_step.dependOn(&run_tests.step);
}

pub fn link(b: *std.Build, step: *CompileStep) *Module {
    if (module) |m| {
        return m;
    }

    module = b.createModule(.{
        .root_source_file = .{ .path = thisPath("/src/root.zig") },
    });

    const module_ = module.?;

    step.root_module.addImport("clowder_ecs", module_);

    return module_;
}
