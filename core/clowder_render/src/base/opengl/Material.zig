const math = @import("clowder_math");

const nat = @import("../../native/opengl.zig");

const opengl = @import("../opengl.zig");
const root = @import("../../root.zig");

const Self = @This();

shader: opengl.Shader,
color: ?root.Color,
texture: ?opengl.Texture,

pub fn init(shader: opengl.Shader, color: ?root.Color, texture: ?opengl.Texture) Self {
    return .{
        .shader = shader,
        .color = color,
        .texture = texture,
    };
}

pub fn select(self: Self) void {
    nat.glUseProgram(self.shader.program);

    const color = self.color orelse root.Color.white;

    const color_uniform = nat.glGetUniformLocation(self.shader.program, "uColor");
    nat.glUniform4f(color_uniform, color.red, color.green, color.blue, color.alpha);

    const texture_uniform = nat.glGetUniformLocation(self.shader.program, "uTexture");
    nat.glUniform1i(texture_uniform, 0);
}
