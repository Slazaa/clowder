const math = @import("clowder_math");

const Vec2u = math.Vec2u;

const nat = @import("../native/win32.zig");

const screen = @import("../screen.zig");

const Screen = screen.Screen(.win32);

/// Returns the size of the `screen`.
pub fn getSize(screen_: Screen) Vec2u {
    switch (screen_) {
        .primary => {
            return Vec2u{
                @intCast(nat.GetSystemMetrics(nat.SM_CXSCREEN)),
                @intCast(nat.GetSystemMetrics(nat.SM_CYSCREEN)),
            };
        },
    }
}
