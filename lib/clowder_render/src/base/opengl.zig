const builtin = @import("builtin");

const nat = @import("../native/opengl.zig");

const Color = @import("../Color.zig");

pub fn clear(color: Color) void {
    nat.glClearColor(color.red, color.green, color.blue, color.alpha);
    nat.glClear(nat.GL_COLOR_BUFFER_BIT | nat.GL_DEPTH_BUFFER_BIT | nat.GL_STENCIL_BUFFER_BIT);
}
