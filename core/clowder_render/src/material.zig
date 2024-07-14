const nat = @import("../native/opengl.zig");

const root = @import("root.zig");

pub fn Material(comptime backend: root.Backend) type {
    return switch (backend) {
        .opengl => @import("base/opengl/Material.zig"),
    };
}
