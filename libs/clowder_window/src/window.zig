const builtin = @import("builtin");

const os = builtin.os;

const cwlmath = @import("clowder_math");

const Vec2u = cwlmath.Vec2u;
const Vec2i = cwlmath.Vec2i;

const screen = @import("screen.zig");

const window_base = switch (os.tag) {
    .windows => @import("window/win32.zig"),
    else => @compileError("OS not supported"),
};

const WindowError = window_base.WindowError;
const WindowBase = window_base.WindowBase;

pub const WindowPos = union(enum) {
    center,
    at: Vec2i,
};

pub const Window = struct {
    const Self = @This();

    base: WindowBase,

    pub fn init(title: []const u8, position: WindowPos, size: Vec2u) WindowError!Self {
        const position_ = switch (position) {
            .center => (screen.getSize(.primary) - size) / Vec2u{ 2, 2 },
            .at => |at| at,
        };

        return .{
            .base = try WindowBase.init(title, position_.x, position_.y, size.x, size.y),
        };
    }

    pub fn deinit(self: Self) void {
        self.base.deinit();
    }
};
