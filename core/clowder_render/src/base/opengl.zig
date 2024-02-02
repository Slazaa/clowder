const builtin = @import("builtin");
const std = @import("std");

const math = @import("clowder_math");

const nat = @import("../native/opengl.zig");

const Color = @import("../Color.zig");

pub const Material = @import("opengl/Material.zig");
pub const RenderObject = @import("opengl/RenderObject.zig");
pub const Shader = @import("opengl/shader.zig").Shader;
pub const Texture = @import("opengl/Texture.zig");

pub fn clear(color: Color, window_size: math.Vec2u) void {
    nat.glViewport(0, 0, @intCast(window_size[0]), @intCast(window_size[1]));

    nat.glClearColor(color.red, color.green, color.blue, color.alpha);
    nat.glClear(nat.GL_COLOR_BUFFER_BIT | nat.GL_DEPTH_BUFFER_BIT | nat.GL_STENCIL_BUFFER_BIT);
}

pub fn render(render_object: RenderObject, default_texture: Texture, texture: ?Texture) void {
    nat.glBindVertexArray(render_object.position_vbo);
    nat.glDrawElements(nat.GL_TRIANGLES, @intCast(render_object.vertices_count), nat.GL_UNSIGNED_INT, null);

    if (texture) |texture_| {
        nat.glBindTexture(nat.GL_TEXTURE_2D, texture_.native);
    } else {
        nat.glBindTexture(nat.GL_TEXTURE_2D, default_texture.native);
    }
}
