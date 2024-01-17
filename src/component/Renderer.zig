const window = @import("clowder_window");
const render = @import("clowder_render");

const Self = @This();

renderer: render.Renderer(.{}),

pub fn init(window_content: window.DefaultWindow.Context) !Self {
    const renderer = try render.Renderer(.{}).init(window_content);
    errdefer renderer.deinit();

    return .{
        .renderer = renderer,
    };
}

pub fn deinit(self: Self) void {
    self.renderer.deinit();
}
