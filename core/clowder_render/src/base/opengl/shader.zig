const std = @import("std");

const nat = @import("../../native/opengl.zig");

pub const Shader = struct {
    const Self = @This();

    const Type = enum { vertex, fragment };

    program: nat.GLuint,

    pub fn fromSources(
        vertex_source: [:0]const u8,
        fragment_source: [:0]const u8,
        report: ?*std.ArrayList(u8),
    ) !Self {
        const program = nat.glCreateProgram();

        const vertex_shader = try compile(.vertex, vertex_source, report);
        const fragment_shader = try compile(.fragment, fragment_source, report);

        nat.glAttachShader(program, vertex_shader);
        nat.glAttachShader(program, fragment_shader);

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
};
