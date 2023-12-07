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

    const renderer = try clw.Renderer(.{}).init(window);
    defer renderer.deinit();

    std.debug.print("Vendor: {?s}\n", .{clw.render.native.opengl.glGetString(clw.render.native.opengl.GL_VENDOR)});
    std.debug.print("Renderer: {?s}\n", .{clw.render.native.opengl.glGetString(clw.render.native.opengl.GL_RENDERER)});
    std.debug.print("Version: {?s}\n", .{clw.render.native.opengl.glGetString(clw.render.native.opengl.GL_VERSION)});
    std.debug.print("Shading language: {?s}\n", .{clw.render.native.opengl.glGetString(clw.render.native.opengl.GL_SHADING_LANGUAGE_VERSION)});

    while (window.open) {
        try window.update();

        renderer.clear(clw.Color.blue);

        renderer.display();
    }
}
