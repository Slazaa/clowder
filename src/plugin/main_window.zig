const std = @import("std");

const root = @import("../root.zig");

pub var main_window: root.DefaultWindow = undefined;

pub fn initSystem(app: *root.App) !void {
    main_window = try root.DefaultWindow.init(
        app.allocator,
        "Clowder Window",
        .center,
        .{ 800, 600 },
    );

    errdefer main_window.deinit();
}

pub fn deinitSystem(_: *root.App) void {
    main_window.deinit();
}

pub fn system(app: *root.App) !void {
    try main_window.update();

    if (main_window.shouldClose()) {
        app.exit();
    }
}

pub const plugin = root.App.Plugin{
    .init_systems = &.{initSystem},
    .deinit_systems = &.{deinitSystem},
    .systems = &.{system},
};
