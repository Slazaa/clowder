const std = @import("std");

const clw = @import("clowder");

fn initSystem(app: *clw.App) !void {
    const square = app.spawn();

    const mesh = try clw.Mesh(.{}).init(
        app.allocator,
        &.{
            .{ -128, -128, 0 },
            .{ -128, 128, 0 },
            .{ 128, -128, 0 },
            .{ 128, 128, 0 },
        },
        &.{},
        &.{
            .{ 0.0, 0.0 },
            .{ 0.0, 1.0 },
            .{ 1.0, 0.0 },
            .{ 1.0, 1.0 },
        },
        &.{
            .{ 0, 1, 2 },
            .{ 1, 3, 2 },
        },
    );

    errdefer mesh.deinit();

    try app.addComponent(square, mesh);

    const image = try clw.loadImage(app.allocator, "examples/texture/example.png");
    defer image.deinit();

    try app.addComponent(square, clw.DefaultTexture.initFromImage(image, .nearest));
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
