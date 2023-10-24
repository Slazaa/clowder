const std = @import("std");

const testing = std.testing;

const clw_window = @import("clowder_window");

const Window = clw_window.Window;

test "Basic test" {
    const allocator = testing.allocator;

    var window = try Window.init(
        allocator,
        "Test window",
        .center,
        .{ 800, 600 },
        true,
    );

    defer window.deinit();

    while (window.open) {
        try window.update();
    }
}
