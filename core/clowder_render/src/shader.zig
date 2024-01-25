const root = @import("root.zig");

pub const Type = enum {
    fragment,
    vertex,
};

pub fn Shader(comptime backend: root.Backend) *const fn (comptime type_: Type) type {
    return switch (backend) {
        .opengl => @import("base/opengl/shader.zig").Shader,
    };
}

pub const DefaultShader = Shader(root.default_backend);
