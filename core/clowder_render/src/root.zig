pub const native = @import("native.zig");
pub const renderer = @import("renderer.zig");

const material = @import("material.zig");
const render_object = @import("render_object.zig");
const shader = @import("shader.zig");
const texture = @import("texture.zig");

pub const Camera = @import("Camera.zig");
pub const Color = @import("Color.zig");
pub const DefaultMaterial = material.DefaultMaterial;
pub const DefaultRenderObject = render_object.DefaultRenderObject;
pub const DefaultShader = shader.DefaultShader;
pub const DefaultTexture = texture.DefaultTexture;
pub const Material = material.Material;
pub const Renderer = renderer.Renderer;
pub const RendererConfig = renderer.Config;
pub const RendererContext = renderer.Context;
pub const RenderObject = render_object.RenderObject;
pub const Shader = shader.Shader;
pub const ShaderType = shader.Type;
pub const Texture = texture.Texture;
pub const Viewport = @import("Viewport.zig");

pub const Backend = enum {
    opengl,
};

pub const default_backend = Backend.opengl;
