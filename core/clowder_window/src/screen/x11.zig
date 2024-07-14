const math = @import("clowder_math");

const Vec2u = math.Vec2u;

const nat = @import("../native/x11.zig");

const screen = @import("../screen.zig");

const Screen = screen.Screen(.x11);

/// Returns the size of the `screen`.
pub fn getSize(screen_: Screen) Vec2u {
    switch (screen_) {
        .primary => {
            return Vec2u{
                @intCast(nat.XWidthOfScreen(0)),
                @intCast(nat.XHeightOfScreen(0)),
            };
        },
    }
}
