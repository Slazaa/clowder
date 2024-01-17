const builtin = @import("builtin");

const os = builtin.os;

/// Represents a screen.
pub const Screen = enum {
    primary,
};

pub usingnamespace switch (os.tag) {
    .windows => @import("screen/win32.zig"),
    else => @compileError("OS not supported"),
};
