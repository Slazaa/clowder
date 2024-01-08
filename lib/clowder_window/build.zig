const std = @import("std");

const clw_math = @import("../clowder_math/build.zig");

var module: ?*std.Build.Module = null;

fn thisPath(comptime suffix: []const u8) []const u8 {
    return comptime (std.fs.path.dirname(@src().file) orelse ".") ++ suffix;
}

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const lib = b.addStaticLibrary(.{
        .name = "clowder_window",
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });

    const sdl = b.dependency("sdl2", .{
        .target = target,
        .optimize = optimize,
    });

    sdl.link(b, lib, .static);
    lib.addModule("sdl2", sdl.getModule(b));

    _ = link(b, lib);

    b.installArtifact(lib);
}

pub fn link(b: *std.Build, step: *std.Build.Step.Compile) *std.Build.Module {
    step.linkLibC();

    if (module) |m| {
        return m;
    }

    module = b.createModule(.{
        .source_file = .{ .path = thisPath("/src/main.zig") },
        .dependencies = &.{
            .{
                .name = "clowder_math",
                .module = clw_math.link(b, step),
            },
        },
    });

    const module_ = module.?;

    step.addModule("clowder_window", module_);

    return module_;
}
