const std = @import("std");

const clw_ecs = @import("core/clowder_ecs/build.zig");
const clw_math = @import("core/clowder_math/build.zig");
const clw_render = @import("core/clowder_render/build.zig");
const clw_window = @import("core/clowder_window/build.zig");

const triangle = @import("examples/triangle/build.zig");

fn thisPath(comptime suffix: []const u8) []const u8 {
    return comptime (std.fs.path.dirname(@src().file) orelse ".") ++ suffix;
}

fn install(b: *std.Build, step: *std.Build.Step.Compile, name: []const u8) !void {
    const name_fmt = "example-{s}";
    const install_desc_fmt = "Build '{s}' example";
    const run_desc_fmt = "Run '{s}' example";

    var name_buf = try std.ArrayList(u8).initCapacity(b.allocator, std.fmt.count(name_fmt, .{name}));
    var install_desc_buf = try std.ArrayList(u8).initCapacity(b.allocator, std.fmt.count(install_desc_fmt, .{name}));
    var run_desc_buf = try std.ArrayList(u8).initCapacity(b.allocator, std.fmt.count(run_desc_fmt, .{name}));

    name_buf.expandToCapacity();
    install_desc_buf.expandToCapacity();
    run_desc_buf.expandToCapacity();

    const full_name = try std.fmt.bufPrint(name_buf.items, name_fmt, .{name});
    const install_desc = try std.fmt.bufPrint(install_desc_buf.items, install_desc_fmt, .{name});
    const run_desc = try std.fmt.bufPrint(run_desc_buf.items, run_desc_fmt, .{name});

    const install_step = b.step(name, install_desc);
    install_step.dependOn(&b.addInstallArtifact(step, .{}).step);

    const run_step = b.step(full_name, run_desc);
    const run_cmd = b.addRunArtifact(step);
    run_cmd.step.dependOn(install_step);
    run_step.dependOn(&run_cmd.step);

    b.getInstallStep().dependOn(install_step);
}

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const lib = b.addStaticLibrary(.{
        .name = "clowder",
        .root_source_file = .{ .path = "src/root.zig" },
        .target = target,
        .optimize = optimize,
    });

    _ = link(b, lib);

    b.installArtifact(lib);

    const examples_dir = try std.fs.cwd().openDir("examples", .{ .iterate = true });
    var examples_dir_iter = examples_dir.iterate();

    while (try examples_dir_iter.next()) |entry| {
        if (entry.kind != .directory) {
            continue;
        }

        try install(b, triangle.build(b, target, optimize), entry.name);
    }
}

pub fn link(b: *std.Build, step: *std.Build.Step.Compile) *std.Build.Module {
    const module = b.createModule(.{
        .root_source_file = .{ .path = thisPath("/src/root.zig") },
        .imports = &.{
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

    step.root_module.addImport("clowder", module);

    return module;
}
