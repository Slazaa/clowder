const sdl = @import("sdl2");

pub const ecs = @import("clowder_ecs");
pub const math = @import("clowder_math");
pub const render = @import("clowder_render");
pub const window = @import("clowder_window");

pub const Color = render.Color;
pub const Renderer = render.Renderer;

pub const Window = window.Window;

pub fn init() !void {
    if (sdl.SDL_Init(sdl.SDL_INIT_VIDEO)) {
        return error.CouldNotInitSdl;
    }
}

pub fn deinit() void {
    sdl.SDL_Quit();
}
