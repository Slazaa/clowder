const std = @import("std");

const heap = std.heap;

const GeneralPurposeAllocator = heap.GeneralPurposeAllocator;

const clw = @import("clowder");

pub fn main() !void {
    var gpa = GeneralPurposeAllocator(.{}){};
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
    }
}
