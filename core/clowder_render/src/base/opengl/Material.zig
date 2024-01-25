const nat = @import("../../native/opengl.zig");

const Shader = @import("shader.zig").Shader;

const Self = @This();

shader_program: nat.GLuint,

pub fn init(shader: Shader) !Self {
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
}
