const builtin = @import("builtin");
const std = @import("std");

const window = @import("clowder_window");
const math = @import("clowder_math");

const root = @import("root.zig");

const Color = @import("Color.zig");

pub const Config = struct {
    render_backend: root.Backend = .opengl,
    window_backend: window.Backend = window.default_backend,
};

pub const Context = struct {
    clear: *const fn (color: Color) void,
};

/// Represents a renderer.
/// The renderer renders stuff on a `Window`.
pub fn Renderer(comptime config: Config) type {
    return struct {
        const Self = @This();

        const backend_base = switch (config.render_backend) {
            .opengl => switch (config.window_backend) {
                .win32 => @import("base/opengl/win32/Renderer.zig"),
            },
        };

        pub const Error = backend_base.Error;

        const Window = window.Window(config.window_backend);

        const Base = backend_base.Base;

        const Material = root.Material(config.render_backend);
        const RenderObject = root.RenderObject(config.render_backend);
        const Texture = root.Texture(config.render_backend);

        window_context: Window.Context,
        backend_base: Base,

        /// Initializes a new `Renderer`.
        /// Deinitialize it with `deinit`.
        pub fn init(window_context: Window.Context) !Self {
            if (window_context.backend != config.window_backend) {
                @compileError("Renderer backend does not match window backend");
            }

            return .{
                .window_context = window_context,
                .backend_base = try Base.init(window_context),
            };
        }

        /// Deinitiliazes the `Renderer`.
        pub fn deinit(self: Self) void {
            self.backend_base.deinit();
        }

        /// Returns a `Context` of the `Renderer`.
        pub fn context(self: *Self) Context {
            return .{
                .renderer = self,

                .clear = Self.clear,
            };
        }

        /// Clears the `Renderer` with `color`.
        pub fn clear(self: Self, color: Color) void {
            self.backend_base.clear(color);
        }

        /// Swaps the buffers.
        pub fn swap(self: Self) void {
            Base.swap(self.window_context);
        }

        /// Renders `render_object` with `material`.
        pub fn render(
            self: Self,
            render_object: RenderObject,
            material: Material,
            camera: root.Camera,
            transform: root.Transform,
            texture: ?Texture,
        ) void {
            self.backend_base.render(
                render_object,
                material,
                camera,
                transform,
                texture,
            );
        }
    };
}
