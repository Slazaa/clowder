const std = @import("std");

const root = @import("../root.zig");

pub fn initSystem(app: *root.App) !void {
    const main_window = app.spawn();

    var window = try root.DefaultWindow.init(
        app.allocator,
        "Clowder Window",
        .center,
        .{ 800, 600 },
        .{},
    );

    errdefer window.deinit();

    const renderer = try root.Renderer(.{}).init(window.context(), null);
    errdefer renderer.deinit();

    try app.addComponent(main_window, window);
    try app.addComponent(main_window, renderer);
}

pub fn deinitSystem(app: *root.App) void {
    var query = app.query(.{ root.DefaultWindow, root.Renderer(.{}) }, .{});

    while (query.next()) |entity| {
        const window = app.getComponent(entity, root.DefaultWindow).?;
        const renderer = app.getComponent(entity, root.Renderer(.{})).?;

        window.deinit();
        renderer.deinit();

        var mesh_query = app.query(.{root.Mesh(.{})}, .{});

        while (mesh_query.next()) |mesh_entity| {
            const mesh = app.getComponent(mesh_entity, root.Mesh(.{})).?;
            mesh.deinit();
        }
    }
}

pub fn system(app: *root.App) !void {
    var query = app.query(.{ root.DefaultWindow, root.Renderer(.{}) }, .{});

    while (query.next()) |entity| {
        const window = app.getComponentPtr(entity, root.DefaultWindow).?;
        const renderer = app.getComponent(entity, root.Renderer(.{})).?;

        try window.update();

        if (window.shouldClose()) {
            app.exit();
        }

        renderer.clear(root.Color.rgb(0.1, 0.1, 0.1));

        var mesh_query = app.query(.{root.Mesh(.{})}, .{});

        while (mesh_query.next()) |mesh_entity| {
            const mesh = app.getComponent(mesh_entity, root.Mesh(.{})).?;
            renderer.render(mesh.render_object);
        }

        renderer.swap();
    }
}

pub const plugin = root.App.Plugin{
    .initSystems = &.{initSystem},
    .deinitSystems = &.{deinitSystem},
    .systems = &.{system},
};
