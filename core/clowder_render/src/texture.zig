const root = @import("root.zig");

pub fn Texture(comptime backend: root.Backend) type {
    return switch (backend) {
        .opengl => @import("base/opengl/Texture.zig"),
    };
}
