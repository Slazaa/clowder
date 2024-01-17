const std = @import("std");

const root = @import("../root.zig");

pub fn initSystem(app: *root.App) !void {
    const main_window = app.spawn();

    var window = try root.DefaultWindow.init(
        app.allocator,
        "Clowder Window",
        .center,
        .{ 800, 600 },
    );

    errdefer window.deinit();

    const renderer = try root.Renderer(.{}).init(window.context());
    errdefer renderer.deinit();

    try app.add(main_window, window);
    try app.add(main_window, renderer);

    try app.addTag(main_window, "main_window");
}

pub fn deinitSystem(app: *root.App) void {
    const main_window = app.getFirstByTag("main_window") orelse return;

    const window = app.get(main_window, root.DefaultWindow).?;
    const renderer = app.get(main_window, root.Renderer(.{})).?;

    window.deinit();
    renderer.deinit();
}

pub fn system(app: *root.App) !void {
    const main_window = app.getFirstByTag("main_window") orelse return;

    const window = app.getPtr(main_window, root.DefaultWindow).?;
    const renderer = app.get(main_window, root.Renderer(.{})).?;

    try window.update();

    if (window.shouldClose()) {
        app.exit();
    }

    renderer.clear(root.Color.black);

    renderer.swap();
}

pub const plugin = root.App.Plugin{
    .initSystems = &.{initSystem},
    .deinitSystems = &.{deinitSystem},
    .systems = &.{system},
};
