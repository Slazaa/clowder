const c = @import("../c.zig");

const cwlmath = @import("clowder_math");

const Vec2u = cwlmath.Vec2u;

const screen_ = @import("../screen.zig");

const Screen = screen_.Screen;

pub fn getSize(screen: Screen) Vec2u {
    var size: Vec2u = undefined;

    switch (screen) {
        .primary => {
            size[0] = @intCast(c.GetSystemMetrics(c.SM_CXSCREEN));
            size[1] = @intCast(c.GetSystemMetrics(c.SM_CYSCREEN));
        },
    }

    return size;
}
