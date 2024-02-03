const math = @import("clowder_math");

const nat = @import("../../native/opengl.zig");

const opengl = @import("../opengl.zig");

const Self = @This();

shader_program: nat.GLuint,

pub fn init(shader: opengl.Shader) !Self {
    const shader_program = nat.glCreateProgram();

    const compiled_shader = try shader.compile();

    nat.glAttachShader(shader_program, compiled_shader.fragment_shader);
    nat.glAttachShader(shader_program, compiled_shader.vertex_shader);

    nat.glLinkProgram(shader_program);
    nat.glValidateProgram(shader_program);

    return .{
        .shader_program = shader_program,
    };
}

pub fn select(self: Self) void {
    nat.glUseProgram(self.shader_program);

    const texture_uniform = nat.glGetUniformLocation(self.shader_program, "tex");
    nat.glUniform1i(texture_uniform, 0);
}
