const root = @import("../root.zig");

pub fn Material(comptime render_backend: root.RenderBackend) type {
    return struct {
        const Self = @This();

        const Shader = root.Shader(render_backend);
        const Texture = root.Texture(render_backend);

        shader: ?Shader = null,
        color: ?root.Color = null,
        texture: ?Texture = null,
    };
}
