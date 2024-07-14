const root = @import("root.zig");

pub fn Shader(comptime backend: root.Backend) type {
    return switch (backend) {
        .opengl => @import("base/opengl/shader.zig").Shader,
    };
}
