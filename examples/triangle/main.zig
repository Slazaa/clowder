const std = @import("std");

const clw = @import("clowder");

fn initWindowSystem(app: *clw.App) !void {
    const window = app.getFirst(.{clw.DefaultWindow}, .{}).?;
    const window_comp = app.getComponent(window, clw.DefaultWindow).?;

    window_comp.setTitle("Triangle");
}

fn initSystem(app: *clw.App) !void {
    const triangle = app.spawn();

    try app.addComponent(triangle, try clw.Mesh(.{}).init(
        app.allocator,
        &.{
            .{ -200, 150, 0 },
            .{ 200, 150, 0 },
            .{ 0, -150, 0 },
        },
        &.{
            clw.Color.red,
            clw.Color.green,
            clw.Color.blue,
        },
        &.{
            .{ 0.0, 0.0 },
            .{ 1.0, 0.0 },
            .{ 0.5, 1.0 },
        },
        &.{
            .{ 0, 1, 2 },
        },
    ));
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();

    var app = try clw.init(allocator, .{
        .plugins = &.{clw.plugin.beginner},
        .initSystems = &.{
            initWindowSystem,
            initSystem,
        },
    });

    defer app.deinit();

    try app.run();
}
