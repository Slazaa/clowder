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
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });

    link(b, lib);

    b.installArtifact(lib);
}

pub fn link(b: *std.Build, step: *CompileStep) *Module {
    if (module) |m| {
        return m;
    }

    module = b.createModule(.{
        .source_file = .{ .path = thisPath("/src/main.zig") },
    });

    const module_ = module.?;

    step.addModule("clowder_ecs", module_);

    return module_;
}