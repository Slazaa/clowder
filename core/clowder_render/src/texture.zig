const root = @import("root.zig");

pub fn Texture(comptime backend: root.Backend) type {
    return switch (backend) {
        .opengl => @import("base/opengl/Texture.zig"),
    };
}

pub const DefaultTexture = Texture(root.default_backend);
