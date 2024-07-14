const std = @import("std");

const math = @import("clowder_math");

const Vec2u = math.Vec2u;

const root = @import("../root.zig");
const window = @import("../window.zig");

const nat = @import("../native/x11.zig");

pub const Error = error{
    CouldNotOpenDispaly,
};

pub const Base = struct {
    const Self = @This();

    display: *nat.Display,
    window: nat.Window,

    pub fn init(title: [:0]const u8, x: i32, y: i32, width: u32, height: u32, config: window.Config) Error!Self {
        _ = title;
        _ = config;

        const display = nat.XOpenDisplay(null) orelse {
            return error.CouldNotOpenDispaly;
        };

        errdefer nat.XCloseDisplay(display);

        const default_root_window = nat.XDefaultRootWindow(display);

        const black_pixel = nat.XBlackPixel(display, 0);
        const white_pixel = nat.XWhitePixel(display, 0);

        const window_ = nat.XCreateSimpleWindow(display, default_root_window, x, y, width, height, 1, black_pixel, white_pixel);
        errdefer nat.XDestroyWindow(display, window_);

        _ = nat.XMapWindow(display, window_);
        _ = nat.XSelectInput(display, window_, nat.ExposureMask);

        return Self{
            .display = display,
            .window = window_,
        };
    }

    pub fn deinit(self: Self) void {
        nat.XDestroyWindow(self.display, self.window);
        nat.XCloseDisplay(self.display);
    }

    pub fn getSize(self: Self) Vec2u {
        var window_attributes = std.mem.zeroes(nat.WindowAttributes);
        _ = nat.XGetWindowAttributes(self.display, self.window, &window_attributes);

        return Vec2u{ @intCast(window_attributes.width), @intCast(window_attributes.height) };
    }

    pub fn setTitle(self: Self, title: [:0]const u8) void {
        _ = nat.XStoreName(self.display, self.window, @ptrCast(title));
    }
};
