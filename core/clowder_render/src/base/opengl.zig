const builtin = @import("builtin");
const std = @import("std");

const math = @import("clowder_math");

const nat = @import("../native/opengl.zig");

const root = @import("../root.zig");

pub const Material = @import("opengl/Material.zig");
pub const RenderObject = @import("opengl/RenderObject.zig");
pub const Shader = @import("opengl/shader.zig").Shader;
pub const Texture = @import("opengl/Texture.zig");

pub fn clear(color: root.Color) void {
    nat.glClearColor(color.red, color.green, color.blue, color.alpha);
    nat.glClear(nat.GL_COLOR_BUFFER_BIT | nat.GL_DEPTH_BUFFER_BIT | nat.GL_STENCIL_BUFFER_BIT);
}

pub fn render(render_object: RenderObject, window_size: math.Vec2u, viewport: root.Viewport, texture: Texture) void {
    nat.glViewport(
        @intFromFloat(viewport.position[0] * @as(f32, @floatFromInt(window_size[0]))),
        @intFromFloat(viewport.position[1] * @as(f32, @floatFromInt(window_size[1]))),
        @intFromFloat(viewport.size[0] * @as(f32, @floatFromInt(window_size[0]))),
        @intFromFloat(viewport.size[1] * @as(f32, @floatFromInt(window_size[1]))),
    );

    nat.glBindVertexArray(render_object.position_vbo);
    nat.glDrawElements(nat.GL_TRIANGLES, @intCast(render_object.vertices_count), nat.GL_UNSIGNED_INT, null);

    nat.glBindTexture(nat.GL_TEXTURE_2D, texture.native);
}
