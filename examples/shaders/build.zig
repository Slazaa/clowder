const std = @import("std");

const clw = @import("../../build.zig");

pub fn build(b: *std.Build, target: std.Build.ResolvedTarget, optimize: std.builtin.OptimizeMode) !void {
    const exe = b.addExecutable(.{
        .name = "shaders",
        .root_source_file = .{ .path = "/src/main.zig" },
        .target = target,
        .optimize = optimize,
    });

    _ = clw.link(b, exe);

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
