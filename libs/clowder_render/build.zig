const builtin = @import("builtin");
const std = @import("std");

const clw_window = @import("../clowder_window/build.zig");

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
        .name = "clowder_render",
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });

    b.installArtifact(lib);
}

pub fn link(b: *std.Build, step: *CompileStep) *Module {
    step.linkLibC();

    switch (builtin.os.tag) {
        .windows => {
            step.linkSystemLibrary("gdi32");
            step.linkSystemLibrary("opengl32");
        },
        else => {},
    }

    if (module) |m| {
        return m;
    }

    module = b.createModule(.{
        .source_file = .{ .path = thisPath("/src/main.zig") },
        .dependencies = &.{
            .{
                .name = "clowder_window",
                .module = clw_window.link(b, step),
            },
        },
    });

    const module_ = module.?;

    step.addModule("clowder_render", module_);

    return module_;
}
