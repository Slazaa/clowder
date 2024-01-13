pub const ecs = @import("clowder_ecs");
pub const math = @import("clowder_math");
pub const render = @import("clowder_render");
pub const window = @import("clowder_window");

pub const Color = render.Color;
pub const Renderer = render.Renderer;

pub const DefaultWindow = window.DefaultWindow;
pub const Window = window.Window;

pub const App = @import("App.zig");

pub const Plugin = *const fn (app: *App) anyerror!void;

pub fn defaultPlugin(app: *App) !void {
    _ = app;
}
