const builtin = @import("builtin");

const nat = @import("../native/opengl.zig");

const Color = @import("../Color.zig");

const backend_base = switch (builtin.os.tag) {
    .windows => @import("opengl/win32.zig"),
    else => @compileError("OS not supported"),
};

pub const Error = backend_base.Error;
pub const BackendBase = backend_base.Base;

pub const Base = struct {
    pub fn clear(color: Color) void {
        nat.glClearColor(color.red, color.green, color.blue, color.alpha);
        nat.glClear(nat.GL_COLOR_BUFFER_BIT | nat.GL_DEPTH_BUFFER_BIT | nat.GL_STENCIL_BUFFER_BIT);
    }
};
