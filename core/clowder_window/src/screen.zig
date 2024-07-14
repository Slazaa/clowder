const root = @import("root.zig");

/// Represents a screen.
pub fn Screen(comptime backend: root.Backend) type {
    return enum {
        primary,

        pub usingnamespace switch (backend) {
            .win32 => @import("screen/win32.zig"),
            .x11 => @import("screen/x11.zig"),
        };
    };
}
