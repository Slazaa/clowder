const std = @import("std");

const clw = @import("clowder");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();

    var window = try clw.Window.init(
        allocator,
        "Triangle",
        .center,
        .{ 800, 600 },
        true,
    );

    defer window.deinit();

    const renderer = try clw.Renderer(.opengl).init(window);
    defer renderer.deinit();

    while (window.open) {
        try window.update();

        renderer.clear(clw.Color.blue);

        renderer.display();
    }
}
