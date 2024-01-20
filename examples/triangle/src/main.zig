const std = @import("std");

const clw = @import("clowder");

pub fn initSystem(app: *clw.App) !void {
    const triangle = app.spawn();

    try app.addComponent(triangle, try clw.Mesh(.{}).init(
        app.allocator,
        &.{
            .{ -0.8, -0.8, 0.0 },
            .{ 0.8, -0.8, 0.0 },
            .{ 0.0, 0.8, 0.0 },
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
