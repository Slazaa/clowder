const std = @import("std");

const clw_ecs = @import("core/clowder_ecs/build.zig");
const clw_math = @import("core/clowder_math/build.zig");
const clw_render = @import("core/clowder_render/build.zig");
const clw_window = @import("core/clowder_window/build.zig");

fn thisPath(comptime suffix: []const u8) []const u8 {
    return comptime (std.fs.path.dirname(@src().file) orelse ".") ++ "/" ++ suffix;
}

fn install(
    b: *std.Build,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
    name: []const u8,
) !void {
    const install_name_fmt = "install-example-{s}";
    const run_name_fmt = "example-{s}";
    const install_desc_fmt = "Build '{s}' example";
    const run_desc_fmt = "Run '{s}' example";

    var install_name_buf = try std.ArrayList(u8).initCapacity(b.allocator, std.fmt.count(install_name_fmt, .{name}));
    errdefer install_name_buf.deinit();

    var run_name_buf = try std.ArrayList(u8).initCapacity(b.allocator, std.fmt.count(run_name_fmt, .{name}));
    errdefer run_name_buf.deinit();

    var install_desc_buf = try std.ArrayList(u8).initCapacity(b.allocator, std.fmt.count(install_desc_fmt, .{name}));
    errdefer install_desc_buf.deinit();

    var run_desc_buf = try std.ArrayList(u8).initCapacity(b.allocator, std.fmt.count(run_desc_fmt, .{name}));
    errdefer run_desc_buf.deinit();

    install_name_buf.expandToCapacity();
    run_name_buf.expandToCapacity();
    install_desc_buf.expandToCapacity();
    run_desc_buf.expandToCapacity();

    const install_name = try std.fmt.bufPrint(install_name_buf.items, install_name_fmt, .{name});
    const run_name = try std.fmt.bufPrint(run_name_buf.items, run_name_fmt, .{name});
    const install_desc = try std.fmt.bufPrint(install_desc_buf.items, install_desc_fmt, .{name});
    const run_desc = try std.fmt.bufPrint(run_desc_buf.items, run_desc_fmt, .{name});

    const source_filename_fmt = comptime thisPath("/examples/{s}/src/main.zig");

    var source_filename_buf = try std.ArrayList(u8).initCapacity(b.allocator, std.fmt.count(source_filename_fmt, .{name}));
    errdefer source_filename_buf.deinit();

    source_filename_buf.expandToCapacity();

    const source_filename = try std.fmt.bufPrint(source_filename_buf.items, source_filename_fmt, .{name});

    const exe = b.addExecutable(.{
        .name = name,
        .root_source_file = .{ .path = source_filename },
        .target = target,
        .optimize = optimize,
    });

    _ = link(b, exe);

    b.installArtifact(exe);

    const install_step = b.step(install_name, install_desc);
    install_step.dependOn(&b.addInstallArtifact(exe, .{}).step);

    const run_step = b.step(run_name, run_desc);
    const run_cmd = b.addRunArtifact(exe);
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

    const module = link(b, lib);

    b.installArtifact(lib);

    const examples_dir = try std.fs.cwd().openDir("examples", .{ .iterate = true });
    var examples_dir_iter = examples_dir.iterate();

    while (try examples_dir_iter.next()) |entry| {
        if (entry.kind != .directory) {
            continue;
        }

        try install(b, target, optimize, entry.name);
    }

    const unit_tests = b.addTest(.{
        .root_source_file = .{ .path = "src/root.zig" },
        .target = target,
        .optimize = optimize,
    });

    var imports_iter = module.import_table.iterator();

    while (imports_iter.next()) |entry| {
        const module_name = entry.key_ptr.*;
        const module_ = entry.value_ptr.*;

        unit_tests.root_module.addImport(module_name, module_);
    }

    const run_unit_tests = b.addRunArtifact(unit_tests);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_unit_tests.step);
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
