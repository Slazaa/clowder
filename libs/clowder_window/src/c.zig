const builtin = @import("builtin");

const os = builtin.os;

pub usingnamespace @cImport({
    switch (os.tag) {
        .windows => @cInclude("windows.h"),
        else => @compileError("OS not supported"),
    }
});
