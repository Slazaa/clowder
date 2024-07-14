const std = @import("std");

pub const ecs = @import("clowder_ecs");
pub const image = @import("clowder_image");
pub const math = @import("clowder_math");
pub const render = @import("clowder_render");
pub const window = @import("clowder_window");

pub usingnamespace ecs;
pub usingnamespace image;
pub usingnamespace math;
pub usingnamespace window;

pub const Camera = render.Camera;
pub const Color = render.Color;
pub const BaseRenderer = render.BaseRenderer;
pub const BaseRenderObject = render.BaseRenderObject;
pub const BaseRenderMaterial = render.BaseMaterial;
pub const BaseShader = render.BaseShader;
pub const BaseTexture = render.BaseTexture;
pub const RenderBackend = render.Backend;
pub const RenderMaterial = render.Material;
pub const Renderer = render.Renderer;
pub const RendererConfig = render.RendererConfig;
pub const RendererContext = render.RendererContext;
pub const RenderObject = render.RenderObject;
pub const Shader = render.Shader;
pub const Texture = render.Texture;
pub const Transform = render.Transform;
pub const Viewport = render.Viewport;

pub const default_render_backend = render.default_backend;

pub const App = @import("App.zig");

pub const bundle = @import("bundle.zig");
pub const component = @import("component.zig");
pub const plugin = @import("plugin.zig");
pub const system = @import("system.zig");

pub const Plugin = plugin.Plugin;

pub usingnamespace component;
pub usingnamespace system;

pub inline fn init(allocator: std.mem.Allocator, app_plugin: Plugin) !App {
    return try App.init(allocator, app_plugin);
}
