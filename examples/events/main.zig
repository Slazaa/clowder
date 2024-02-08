const std = @import("std");

const clw = @import("clowder");

fn initSystem(app: *clw.App) !void {
    const rect = app.spawn();

    const rectangle_bundle = try clw.bundle.Rectangle(.{}).init(
        app.allocator,
        .{ 256, 256 },
        clw.Color.red,
    );

    errdefer rectangle_bundle.deinit();

    try app.addBundle(rect, rectangle_bundle);
}

fn system(app: *clw.App) !void {
    const window_entity = app.getFirst(.{clw.DefaultWindow}, .{}).?;
    const window = app.getComponent(window_entity, clw.DefaultWindow).?;

    if (window.isKeyPressed(.space)) {
        std.debug.print("Space pressed!", .{});
    }
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();

    var app = try clw.init(allocator, .{
        .plugins = &.{clw.plugin.beginner},
        .initSystems = &.{initSystem},
        .systems = &.{system},
    });

    defer app.deinit();

    try app.run();
}
