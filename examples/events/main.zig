const std = @import("std");

const clw = @import("clowder");

fn initSystem(app: *clw.App) !void {
    const rect = app.spawn();
    _ = rect;
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
