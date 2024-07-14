pub const native = @import("native.zig");
pub const renderer = @import("renderer.zig");

const material = @import("material.zig");
const render_object = @import("render_object.zig");
const shader = @import("shader.zig");
const texture = @import("texture.zig");

pub const BaseMaterial = material.Material;
pub const BaseRenderer = renderer.Renderer;
pub const BaseRenderObject = render_object.RenderObject;
pub const BaseShader = shader.Shader;
pub const BaseTexture = texture.Texture;
pub const Camera = @import("Camera.zig");
pub const Color = @import("Color.zig");
pub const RendererConfig = renderer.Config;
pub const RendererContext = renderer.Context;
pub const Transform = @import("Transform.zig");
pub const Viewport = @import("Viewport.zig");

pub const Backend = enum {
    opengl,
};

pub const default_backend = Backend.opengl;

pub const Material = BaseMaterial(default_backend);
pub const Renderer = BaseRenderer(.{});
pub const RenderObject = BaseRenderObject(default_backend);
pub const Shader = BaseShader(default_backend);
pub const Texture = Texture(default_backend);
