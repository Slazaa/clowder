const std = @import("std");

const root = @import("../root.zig");

pub fn initSystem(app: *root.App) !void {
    const main_window = app.spawn();

    var window = try root.Window.init(
        app.allocator,
        "Clowder Window",
        .center,
        .{ 800, 600 },
    );

    errdefer window.deinit();

    const renderer = try root.Renderer.init(window.window.context());
    errdefer renderer.deinit();

    try app.add(main_window, window);
    try app.add(main_window, renderer);

    try app.addTag(main_window, "main_window");
}

pub fn deinitSystem(app: *root.App) void {
    var query = app.query(.{root.Window}, .{});

    while (query.next()) |entity| {
        const window = app.get(entity, root.Window).?;
        window.deinit();
    }
}

pub fn system(app: *root.App) !void {
    const main_window = app.getFistByTag("main_window") orelse return;

    const window = app.getPtr(main_window, root.Window).?;
    const renderer = app.get(main_window, root.Renderer).?;

    try window.window.update();

    if (window.window.shouldClose()) {
        app.exit();
    }

    renderer.renderer.clear(root.Color.black);

    renderer.renderer.swap();
}

pub const plugin = root.App.Plugin{
    .initSystems = &.{initSystem},
    .deinitSystems = &.{deinitSystem},
    .systems = &.{system},
};
