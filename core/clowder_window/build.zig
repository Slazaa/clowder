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
        .root_source_file = .{ .path = "src/root.zig" },
        .target = target,
        .optimize = optimize,
    });

    _ = link(b, lib);

    b.installArtifact(lib);
}

pub fn link(b: *std.Build, step: *std.Build.Step.Compile) *std.Build.Module {
    step.linkLibC();

    if (module) |m| {
        return m;
    }

    module = b.createModule(.{
        .root_source_file = .{ .path = thisPath("/src/root.zig") },
        .imports = &.{
            .{
                .name = "clowder_math",
                .module = clw_math.link(b, step),
            },
        },
    });

    const module_ = module.?;

    step.root_module.addImport("clowder_window", module_);

    return module_;
}
