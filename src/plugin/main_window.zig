const std = @import("std");

const root = @import("../root.zig");

pub const MainWindow = struct { root.DefaultWindow };

pub fn initSystem(app: *root.App) !void {
    var window_ = try root.DefaultWindow.init(
        app.allocator,
        "Clowder Window",
        .center,
        .{ 800, 600 },
    );

    errdefer window_.deinit();

    try app.addResource(MainWindow{window_});
}

pub fn deinitSystem(app: *root.App) void {
    var main_window = (app.getResourcePtr(MainWindow) orelse return)[0];
    main_window.deinit();
}

pub fn system(app: *root.App) !void {
    var main_window = (app.getResource(MainWindow) orelse return)[0];

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
