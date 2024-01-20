const nat = @import("../native/win32.zig");

const cwlmath = @import("clowder_math");

const Vec2u = cwlmath.Vec2u;

const screen_ = @import("../screen.zig");

const Screen = screen_.Screen;

/// Returns the size of the `screen`.
pub fn getSize(screen: Screen) Vec2u {
    var size: Vec2u = undefined;

    switch (screen) {
        .primary => {
            size[0] = @intCast(nat.GetSystemMetrics(nat.SM_CXSCREEN));
            size[1] = @intCast(nat.GetSystemMetrics(nat.SM_CYSCREEN));
        },
    }

    return size;
}
