const std = @import("std");

const clw = @import("clowder");

fn initSystem(app: *clw.App) !void {
    const image = try clw.loadImage(app.allocator, "examples/texture/assets/example.png");
    defer image.deinit();
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
