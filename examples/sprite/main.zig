const std = @import("std");

const clw = @import("clowder");

fn initWindowSystem(app: *clw.App) !void {
    const window = app.getFirst(.{clw.DefaultWindow}, .{}).?;
    const window_comp = app.getComponent(window, clw.DefaultWindow).?;

    window_comp.setTitle("Sprite");
}

fn initSystem(app: *clw.App) !void {
    const current_path = comptime std.fs.path.dirname(@src().file).?;

    const sprite = app.spawn();

    const image = try clw.loadImageFromPath(app.allocator, current_path ++ "/example.png");
    defer image.deinit();

    const sprite_bundle = try clw.bundle.Sprite(.{}).init(
        app.allocator,
        .{ 256, 256 },
        null,
        .{ .texture = clw.DefaultTexture.initFromImage(image, .{}) },
    );

    errdefer sprite_bundle.deinit();

    try app.addBundle(sprite, sprite_bundle);
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
