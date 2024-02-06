const std = @import("std");

const clw = @import("clowder");

fn initSystem(app: *clw.App) !void {
    const rect = app.spawn();

    const rect_bundle = try clw.bundle.Rectangle(.{}).init(
        app.allocator,
        .{ 256, 256 },
    );

    try app.addBundle(rect, rect_bundle);

    const image = try clw.loadImage(app.allocator, "examples/texture/example.png");
    defer image.deinit();

    try app.addComponent(rect, clw.DefaultTexture.initFromImage(image, .nearest));
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
