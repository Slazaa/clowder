const root = @import("root.zig");

pub fn RenderObject(comptime backend: root.Backend) type {
    return switch (backend) {
        .opengl => @import("base/opengl/RenderObject.zig"),
    };
}
