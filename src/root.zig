pub const ecs = @import("clowder_ecs");
pub const math = @import("clowder_math");
pub const render = @import("clowder_render");
pub const window = @import("clowder_window");

pub const Color = render.Color;
pub const Renderer = render.Renderer;

pub const DefaultWindow = window.DefaultWindow;
pub const Window = window.Window;

pub const App = @import("App.zig");

pub const System = App.System;
pub const Plugin = App.Plugin;

pub const plugin = @import("plugin.zig");

pub const MainWindow = plugin.main_window.MainWindow;

pub const default_plugin = Plugin{
    .plugins = &.{
        plugin.main_window.plugin,
    },
};
