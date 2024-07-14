const builtin = @import("builtin");

pub const native = @import("native.zig");
pub const screen = @import("screen.zig");
pub const window = @import("window.zig");

const event = @import("event.zig");

pub const Screen = screen.Screen;

pub const BaseWindow = window.Window;
pub const Event = event.Event;
pub const WindowPos = window.WindowPos;

pub const Backend = enum {
    win32,
    x11,
};

pub const default_backend: Backend = switch (builtin.os.tag) {
    .windows => .win32,
    .linux => .x11,
    else => @compileError("OS not supported"),
};

pub const Window = BaseWindow(default_backend);
