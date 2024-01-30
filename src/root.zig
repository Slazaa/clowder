const std = @import("std");

pub const ecs = @import("clowder_ecs");
pub const image = @import("clowder_image");
pub const math = @import("clowder_math");
pub const render = @import("clowder_render");
pub const window = @import("clowder_window");

pub usingnamespace ecs;
pub usingnamespace image;
pub usingnamespace math;
pub usingnamespace render;
pub usingnamespace window;

pub const App = @import("App.zig");

pub const System = App.System;
pub const Plugin = App.Plugin;

pub const component = @import("component.zig");
pub const plugin = @import("plugin.zig");

pub usingnamespace component;

pub const default_plugin = Plugin{
    .plugins = &.{
        plugin.default_window.plugin,
    },
};

pub inline fn init(allocator: std.mem.Allocator, app_plugin: Plugin) !App {
    return try App.init(allocator, app_plugin);
}
