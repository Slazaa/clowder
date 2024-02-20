const std = @import("std");

const clw = @import("clowder");

pub const PieceKind = enum { i, j, l, o, s, t, z };

fn initSystem(app: *clw.App) !void {
    const grid = app.spawn();

    const tilemap = try clw.Tilemap(.{}).init(app.allocator, .{ 50, 50 }, .{ 10, 20 });
    errdefer tilemap.deinit();

    try app.addComponent(grid, tilemap);
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();

    var app = try clw.init(allocator, .{
        .plugins = &.{clw.plugin.beginner},
        .initSystems = &.{initSystem},
    });

    defer app.deinit();

    try app.run();
}
