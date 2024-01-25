const std = @import("std");

const nat = @import("../../native/opengl.zig");

const Type = @import("../../shader.zig").Type;

pub const CompiledShader = nat.GLuint;

pub fn Shader(comptime type_: Type) type {
    return struct {
        const Self = @This();

        source: [:0]const u8,

        pub fn fromSource(source: [:0]const u8) Self {
            return .{
                .source = source,
            };
        }

        pub fn compile(self: Self, report: ?*std.ArrayList(u8)) !CompiledShader {
            const gl_type = switch (type_) {
                .fragment => nat.GL_FRAGMENT_SHADER,
                .vertex => nat.GL_VERTEX_SHADER,
            };

            const shader = nat.glCreateShader(gl_type);
            errdefer nat.glDeleteShader(shader);

            nat.glShaderSource(shader, 1, @ptrCast(&self.source), null);
            nat.glCompileShader(shader);

            var compiled: nat.GLint = undefined;

            nat.glGetShaderiv(shader, nat.GL_COMPILE_STATUS, &compiled);

            if (compiled == nat.GL_FALSE) {
                if (report) |report_| {
                    var max_len: nat.GLint = undefined;

                    nat.glGetShaderiv(shader, nat.GL_INFO_LOG_LENGTH, &max_len);

                    try report_.ensureTotalCapacity(@intCast(max_len));
                    report_.expandToCapacity();

                    nat.glGetShaderInfoLog(shader, max_len, &max_len, @ptrCast(report_.items));
                }

                return error.CouldNotCompileShader;
            }

            return shader;
        }
    };
}
