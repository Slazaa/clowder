const std = @import("std");

const clw = @import("clowder");

fn initSystem(app: *clw.App) !void {
    const square = app.spawn();

    try app.addComponent(square, try clw.Mesh(.{}).init(
        app.allocator,
        &.{
            .{ -0.5, -0.5, 0.0 },
            .{ -0.5, 0.5, 0.0 },
            .{ 0.5, -0.5, 0.0 },
            .{ 0.5, 0.5, 0.0 },
        },
        &.{},
        &.{
            .{ 0.0, 1.0 },
            .{ 0.0, 0.0 },
            .{ 1.0, 1.0 },
            .{ 1.0, 0.0 },
        },
        &.{
            .{ 0, 1, 2 },
            .{ 1, 3, 2 },
        },
    ));

    const image = try clw.loadImage(app.allocator, "examples/texture/example.tga");
    defer image.deinit();

    try app.addComponent(square, clw.DefaultTexture.initFromImage(image, .nearest));
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();

    var app = try clw.init(allocator, .{
        .plugins = &.{clw.default_plugin},
        .initSystems = &.{initSystem},
    });

    defer app.deinit();

    try app.run();
}
