const std = @import("std");

const clw = @import("clowder");

fn initSystem(app: *clw.App) !void {
    const cube = app.spawn();

    try app.addComponent(cube, clw.Mesh.init(
        app.allocator,
        &.{
            // Z
            -0.5, -0.5, -0.5,
            -0.5, 0.5,  -0.5,
            0.5,  -0.5, -0.5,
            0.5,  0.5,  -0.5,

            -0.5, -0.5, 0.5,
            -0.5, 0.5,  0.5,
            0.5,  -0.5, 0.5,
            0.5,  0.5,  0.5,
        },
        &.{},
    ));
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer gpa.deinit();

    const allocator = gpa.allocator();

    var app = try clw.init(allocator, .{
        .plugins = &.{clw.default_plugin},
        .initSystems = &.{initSystem},
    });

    defer app.deinit();

    try app.run();
}
