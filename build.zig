const std = @import("std");

const clw_math = @import("libs/clowder_math/build.zig");
const clw_window = @import("libs/clowder_window/build.zig");

const CompileStep = std.Build.Step.Compile;
const Module = std.Build.Module;

fn thisPath(comptime suffix: []const u8) []const u8 {
    return comptime (std.fs.path.dirname(@src().file) orelse ".") ++ suffix;
}

pub fn build(b: *std.Build) void {
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

    const main_tests = b.addTest(.{
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });

    _ = link(b, main_tests);

    const run_main_tests = b.addRunArtifact(main_tests);

    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&run_main_tests.step);
}

pub fn link(b: *std.Build, step: *CompileStep) *Module {
    const clw_math_module = clw_math.link(b, step);
    const clw_window_module = clw_window.link(b, step);

    const module = b.createModule(.{
        .source_file = .{ .path = thisPath("/src/main.zig") },
        .dependencies = &.{
            .{
                .name = "clowder_math",
                .module = clw_math_module,
            },
            .{
                .name = "clowder_window",
                .module = clw_window_module,
            },
        },
    });

    step.addModule("clowder", module);

    return module;
}
