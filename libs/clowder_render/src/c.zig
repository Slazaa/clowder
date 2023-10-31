const builtin = @import("builtin");

pub usingnamespace @cImport({
    switch (builtin.os.tag) {
        .windows => @cInclude("windows.h"),
        else => @compileError("OS not supported"),
    }
    @cInclude("GL/gl.h");
});
