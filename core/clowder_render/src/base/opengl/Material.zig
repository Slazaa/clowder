const nat = @import("../native/opengl.zig");

const FragmentShader = @import("FragmentShader.zig");
const VertexShader = @import("VertexShader.zig");

const Self = @This();

shader_program: nat.GLuint,

pub fn init(vertex_shader: VertexShader, fragment_shader: FragmentShader) Self {
    _ = fragment_shader;
    _ = vertex_shader;
}
