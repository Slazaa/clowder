const std = @import("std");

const clw = @import("clowder");

fn initSystem(app: *clw.App) !void {
    const quad = app.spawn();

    try app.addComponent(quad, try clw.Mesh(.{}).init(
        app.allocator,
        &.{
            .{ -0.5, -0.5, 0.0 },
            .{ 0.5, -0.5, 0.0 },
            .{ -0.5, 0.5, 0.0 },
            .{ 0.5, 0.5, 0.0 },

            .{ -0.5, -0.5, 1.0 },
            .{ 0.5, -0.5, 1.0 },
            .{ -0.5, 0.5, 1.0 },
            .{ 0.5, 0.5, 1.0 },
        },
        &.{
            clw.Color.red,
            clw.Color.green,
            clw.Color.blue,
            clw.Color.red,
        },
        &.{
            .{ 2, 0, 1 },
            .{ 1, 3, 2 },
        },
    ));
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();

    var app = try clw.App.init(allocator, .{
        .plugins = &.{clw.default_plugin},
        .initSystems = &.{initSystem},
    });

    defer app.deinit();

    try app.run();
}
