const std = @import("std");

const builtin = std.builtin;
const zig = std.zig;

const Build = std.Build;
const CompileStep = Build.CompileStep;
const CrossTarget = zig.CrossTarget;
const OptimizeMode = builtin.OptimizeMode;

const clw = @import("../../build.zig");

fn thisPath(comptime suffix: []const u8) []const u8 {
    return comptime (std.fs.path.dirname(@src().file) orelse ".") ++ suffix;
}

pub fn build(b: *Build, target: CrossTarget, optimize: OptimizeMode) *CompileStep {
    const exe = b.addExecutable(.{
        .name = "triangle",
        .root_source_file = .{ .path = thisPath("/src/main.zig") },
        .target = target,
        .optimize = optimize,
    });

    _ = clw.link(b, exe);

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    return exe;
}
