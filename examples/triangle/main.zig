const std = @import("std");

// Import Clowder!
const clw = @import("clowder");

// This is our init system, it will be called once when initalizing the `App`.
fn initSystem(app: *clw.App) !void {
    // In there, we spawn a new entity, that represents our triangle.
    // Note that entities are just IDs and they don't hold any data.
    const triangle = app.spawn();

    // Then, we add a `Mesh` component to our entity.
    // Remember, entities are assigned components that we can then use in our systems.
    // In the case of `Mesh` components, the `default_plugin` will take care of
    // rendering them.
    try app.addComponent(triangle, try clw.Mesh(.{}).init(
        app.allocator,
        // We first set the vertices positions.
        &.{
            .{ -200, 150, 0 },
            .{ 200, 150, 0 },
            .{ 0, -150, 0 },
        },
        // Then we set their colors.
        &.{
            clw.Color.red,
            clw.Color.green,
            clw.Color.blue,
        },
        // This is used when dealing with textures.
        &.{
            .{ 0.0, 0.0 },
            .{ 1.0, 0.0 },
            .{ 0.5, 1.0 },
        },
        // And then we set their indices.
        // For each index, the associated vertex will be drawn in the given order.
        &.{
            .{ 0, 1, 2 },
        },
    ));
}

pub fn main() !void {
    // This is the allocator for our `App`.
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();

    // Here we create our `App`.
    var app = try clw.init(allocator, .{
        // We set our plugins, wich here is the beginner one.
        // This plugin sets up a basic environment.
        .plugins = &.{clw.plugin.beginner},
        // And we add our init systems, here being `initSystem`.
        .initSystems = &.{initSystem},
    });

    // We need to deinitialize our `App` at the end of the program.
    defer app.deinit();

    // Finally, we can run our `App`!
    try app.run();
}
