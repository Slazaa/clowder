const nat = @import("../../native/opengl.zig");

const Shader = @import("shader.zig").Shader;

const Self = @This();

shader_program: nat.GLuint,

pub fn init(vertex_shader: Shader(.vertex), fragment_shader: Shader(.fragment)) !Self {
    const shader_program = nat.glCreateProgram();

    const compiled_vertex_shader = try vertex_shader.compile(null);
    const compiled_fragment_shader = try fragment_shader.compile(null);

    nat.glAttachShader(shader_program, compiled_vertex_shader);
    nat.glAttachShader(shader_program, compiled_fragment_shader);

    nat.glLinkProgram(shader_program);
    nat.glValidateProgram(shader_program);

    return .{
        .shader_program = shader_program,
    };
}

pub fn select(self: Self) void {
    nat.glUseProgram(self.shader_program);
}
