const std = @import("std");

const nat = @import("../../native/opengl.zig");

pub const Shader = struct {
    const Self = @This();

    const Type = enum {
        fragment,
        vertex,
    };

    program: nat.GLuint,

    pub fn fromSources(
        fragment_source: [:0]const u8,
        vertex_source: [:0]const u8,
        report: ?*std.ArrayList(u8),
    ) !Self {
        const program = nat.glCreateProgram();

        const fragment_shader = try compile(.fragment, fragment_source, report);
        const vertex_shader = try compile(.vertex, vertex_source, report);

        nat.glAttachShader(program, fragment_shader);
        nat.glAttachShader(program, vertex_shader);

        nat.glLinkProgram(program);
        nat.glValidateProgram(program);

        return .{
            .program = program,
        };
    }

    fn compile(type_: Type, source: [:0]const u8, report: ?*std.ArrayList(u8)) !nat.GLuint {
        const gl_type: nat.GLenum = switch (type_) {
            .fragment => nat.GL_FRAGMENT_SHADER,
            .vertex => nat.GL_VERTEX_SHADER,
        };

        const shader = nat.glCreateShader(gl_type);
        errdefer nat.glDeleteShader(shader);

        nat.glShaderSource(shader, 1, @ptrCast(&source), null);
        nat.glCompileShader(shader);

        var compiled: nat.GLint = undefined;

        nat.glGetShaderiv(shader, nat.GL_COMPILE_STATUS, &compiled);

        if (compiled == nat.GL_FALSE) {
            if (report) |report_| {
                var max_len: nat.GLint = undefined;

                nat.glGetShaderiv(shader, nat.GL_INFO_LOG_LENGTH, &max_len);

                try report_.resize(@intCast(max_len));

                nat.glGetShaderInfoLog(shader, max_len, &max_len, @ptrCast(report_.items));
            }

            return error.CouldNotCompileShader;
        }

        return shader;
    }

    pub fn default() !Self {
        const vertex_shader_source =
            \\#version 450 core
            \\
            \\layout(location = 0) in vec3 aPosition;
            \\layout(location = 1) in vec4 aColor;
            \\layout(location = 2) in vec2 aUvCoords;
            \\
            \\out vec4 fColor;
            \\out vec2 fUvCoords;
            \\
            \\uniform mat4 uTransform;
            \\
            \\void main() {
            \\    gl_Position = uTransform * vec4(aPosition, 1.0f);
            \\
            \\    fColor = aColor;
            \\    fUvCoords = aUvCoords;
            \\}
        ;

        const fragment_shader_source =
            \\#version 450 core
            \\
            \\in vec4 fColor;
            \\in vec2 fUvCoords;
            \\
            \\out vec4 color;
            \\
            \\uniform vec4 uColor;
            \\uniform sampler2D uTexture;
            \\
            \\void main() {
            \\    color = texture(uTexture, fUvCoords) * fColor * uColor;
            \\}
        ;

        return try fromSources(
            fragment_shader_source,
            vertex_shader_source,
            null,
        );
    }
};
