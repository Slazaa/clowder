const clw_window = @import("clowder_window");

const Window = clw_window.Window;

const opengl = @import("Renderer/opengl.zig");

pub const Error = opengl.Error;

const Self = @This();

pub const Base = union(enum) {
    opengl: opengl.ContextBase,
};

base: Base,

pub fn init(window: Window) Error!Self {
    const base = switch (window.render_backend) {
        .opengl => try opengl.ContextBase.init(),
    };

    return .{
        .base = base,
    };
}
