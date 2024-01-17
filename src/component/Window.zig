const std = @import("std");

const window = @import("clowder_window");
const render = @import("clowder_render");
const math = @import("clowder_math");

const Self = @This();

window: window.DefaultWindow,

pub fn init(
    allocator: std.mem.Allocator,
    title: [:0]const u8,
    position: window.WindowPos,
    size: math.Vec2u,
) !Self {
    const window_ = try window.DefaultWindow.init(allocator, title, position, size);
    errdefer window_.deinit();

    return .{
        .window = window_,
    };
}

pub fn deinit(self: Self) void {
    self.window.deinit();
}
