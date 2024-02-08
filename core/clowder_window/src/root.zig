pub const native = @import("native.zig");
pub const screen = @import("screen.zig");
pub const window = @import("window.zig");

const event = @import("event.zig");

pub const Screen = screen.Screen;

pub const DefaultWindow = window.DefaultWindow;
pub const Event = event.Event;
pub const Window = window.Window;
pub const WindowPos = window.WindowPos;

pub const Backend = enum {
    win32,
};

pub const default_backend = window.default_backend;
