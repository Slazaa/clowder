const builtin = @import("builtin");
const std = @import("std");

const clw_image = @import("../clowder_image/build.zig");
const clw_math = @import("../clowder_math/build.zig");
const clw_window = @import("../clowder_window/build.zig");

var module: ?*std.Build.Module = null;

fn thisPath(comptime suffix: []const u8) []const u8 {
    return comptime (std.fs.path.dirname(@src().file) orelse ".") ++ suffix;
}

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const lib = b.addStaticLibrary(.{
        .name = "clowder_render",
        .root_source_file = .{ .cwd_relative = "src/root.zig" },
        .target = target,
        .optimize = optimize,
    });

    b.installArtifact(lib);
}

pub fn link(b: *std.Build, step: *std.Build.Step.Compile) *std.Build.Module {
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
        .root_source_file = .{ .cwd_relative = thisPath("/src/root.zig") },
        .imports = &.{
            .{
                .name = "clowder_image",
                .module = clw_image.link(b, step),
            },
            .{
                .name = "clowder_math",
                .module = clw_math.link(b, step),
            },
            .{
                .name = "clowder_window",
                .module = clw_window.link(b, step),
            },
        },
    });

    const module_ = module.?;

    step.root_module.addImport("clowder_render", module_);

    return module_;
}
