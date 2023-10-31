const builtin = @import("builtin");

const clw_window = @import("clowder_window");

const Window = clw_window.Window;

const win32_opengl = @import("Renderer/opengl/win32.zig");

pub const Error = win32_opengl.Error;

pub const Backend = enum {
    opengl,
};

pub fn Renderer(comptime backend: Backend) type {
    return struct {
        const Self = @This();

        const BackendBase = switch (backend) {
            .opengl => switch (builtin.os.tag) {
                .windows => win32_opengl.Base,
                else => @compileError("OS not supported"),
            },
        };

        backend_base: BackendBase,

        pub fn init(window: Window) Error!Self {
            return .{
                .backend_base = try BackendBase.init(window),
            };
        }

        pub fn deinit(self: Self) void {
            _ = self;
        }
    };
}
