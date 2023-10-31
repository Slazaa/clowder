const c = @import("../c.zig");

const Color = @import("../Color.zig");

pub const Base = struct {
    pub fn clear(color: Color) void {
        c.glClearColor(color.red, color.green, color.blue, color.alpha);
        c.glClear(c.GL_COLOR_BUFFER_BIT | c.GL_DEPTH_BUFFER_BIT);
    }
};
