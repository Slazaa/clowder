const std = @import("std");

const Build = std.Build;
const CompileStep = Build.Step.Compile;
const Module = Build.Module;

const clw_ecs = @import("lib/clowder_ecs/build.zig");
const clw_math = @import("lib/clowder_math/build.zig");
const clw_render = @import("lib/clowder_render/build.zig");
const clw_window = @import("lib/clowder_window/build.zig");

const triangle = @import("examples/triangle/build.zig");

fn thisPath(comptime suffix: []const u8) []const u8 {
    return comptime (std.fs.path.dirname(@src().file) orelse ".") ++ suffix;
}

fn install(b: *Build, step: *CompileStep, comptime name: []const u8) void {
    const install_step = b.step(name, "Build '" ++ name ++ "' demo");
    install_step.dependOn(&b.addInstallArtifact(step, .{}).step);

    const run_step = b.step(name ++ "-example", "Run '" ++ name ++ "' demo");
    const run_cmd = b.addRunArtifact(step);
    run_cmd.step.dependOn(install_step);
    run_step.dependOn(&run_cmd.step);

    b.getInstallStep().dependOn(install_step);
}

pub fn build(b: *Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const lib = b.addStaticLibrary(.{
        .name = "clowder",
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });

    _ = link(b, lib);

    b.installArtifact(lib);

    install(b, triangle.build(b, target, optimize), "triangle");
}

pub fn link(b: *Build, step: *CompileStep) *Module {
    const module = b.createModule(.{
        .source_file = .{ .path = thisPath("/src/main.zig") },
        .dependencies = &.{
            .{
                .name = "clowder_ecs",
                .module = clw_ecs.link(b, step),
            },
            .{
                .name = "clowder_math",
                .module = clw_math.link(b, step),
            },
            .{
                .name = "clowder_render",
                .module = clw_render.link(b, step),
            },
            .{
                .name = "clowder_window",
                .module = clw_window.link(b, step),
            },
        },
    });

    step.addModule("clowder", module);

    return module;
}
