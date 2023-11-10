const builtin = @import("builtin");

pub usingnamespace switch (builtin.os.tag) {
    .windows => @import("base/win32.zig"),
    else => @compileError("OS not supported"),
};
