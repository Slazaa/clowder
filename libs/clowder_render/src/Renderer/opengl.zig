const c = @import("../c.zig");

const cwl_window = @import("clowder_window");

const Window = cwl_window.Window;

pub const Error = error{};

pub const Base = struct {
    const Self = @This();

    pub fn init(window: Window) Error!Self {
        _ = window;
    }
};
