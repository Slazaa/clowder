const std = @import("std");

// Import Clowder!
const clw = @import("clowder");

// This is our init systme, it will be executed once when initalizing the `App`.
pub fn initSystem(app: *clw.App) !void {
    // In there, we spawn a new entity, that we store in `triangle`.
    // Note that entities are just IDs and they don't hold any data.
    const triangle = app.spawn();

    // Then, we add a `Mesh` component to our entity.
    // Remember, entities are assigned components that we can then use in our systems.
    try app.addComponent(triangle, try clw.Mesh(.{}).init(
        app.allocator,
        // We first set the vertices positions.
        &.{
            .{ -0.8, -0.8, 0.0 },
            .{ 0.8, -0.8, 0.0 },
            .{ 0.0, 0.8, 0.0 },
        },
        // And then their colors.
        &.{
            clw.Color.red,
            clw.Color.green,
            clw.Color.blue,
        },
    ));
}

pub fn main() !void {
    // Classic GPA!
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();

    // Here we create our `App`.
    var app = try clw.App.init(allocator, .{
        // We set our plugins, wich here is the default one.
        .plugins = &.{clw.default_plugin},
        // And we add our init systems, here being `initSystem`.
        .initSystems = &.{initSystem},
    });

    // We need to deinitialize our `App` at the end of the program.
    defer app.deinit();

    // Finally, we can run our `App`!
    try app.run();
}
