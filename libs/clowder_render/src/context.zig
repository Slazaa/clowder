const clw_window = @import("clowder_window");

const Window = clw_window.Window;

const opengl = @import("context/opengl.zig");

pub const ContextError = opengl.ContextError;

pub const ContextBase = union(enum) {
    opengl: opengl.ContextBase,
};

pub const Context = struct {
    const Self = @This();

    base: ContextBase,

    pub fn init(window: Window) ContextBase!Self {
        const base = switch (window.render_backend) {
            .opengl => try opengl.ContextBase.init(),
        };

        return .{
            .base = base,
        };
    }
};
