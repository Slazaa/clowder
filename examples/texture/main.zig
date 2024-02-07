const std = @import("std");

const clw = @import("clowder");

fn initSystem(app: *clw.App) !void {
    const sprite = app.spawn();

    const image = try clw.loadImage(app.allocator, "examples/texture/example.png");
    defer image.deinit();

    try app.addBundle(
        sprite,
        try clw.bundle.Sprite(.{}).init(
            app.allocator,
            .{ 256, 256 },
            .{ .texture = clw.DefaultTexture.initFromImage(image, .nearest) },
        ),
    );
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
