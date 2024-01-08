const sdl = @import("sdl2");

const Window = @import("../window.zig");

const Event = Window.Event;

pub const Error = error{
    CouldNotInitWindow,
};

pub const Base = struct {
    const Self = @This();

    window: *sdl.SDL_Window,

    pub fn init(
        title: [:0]const u8,
        x: i32,
        y: i32,
        width: u32,
        height: u32,
    ) Error!Self {
        const window = sdl.SDL_CreateWindow(title, x, y, width, height, 0) orelse {
            return error.CouldNotInitWindow;
        };

        errdefer sdl.SDL_DestroyWindow(window);

        return .{
            .window = window,
        };
    }

    pub fn deinit(self: Self) void {
        sdl.SDL_DestroyWindow(self.window);
    }

    pub fn pollEvent(_: Self) ?Event {
        const event: sdl.SDL_Event = undefined;

        while (sdl.SDL_PollEvent(&event) != 0) {
            return switch (event.type) {
                sdl.SDL_QUIT => .close,
                else => null,
            };
        }

        return null;
    }
};
