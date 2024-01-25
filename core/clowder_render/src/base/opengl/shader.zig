const std = @import("std");

const nat = @import("../../native/opengl.zig");

pub const CompiledShader = struct {
    fragment_shader: nat.GLuint,
    vertex_shader: nat.GLuint,
};

pub const Shader = struct {
    const Self = @This();

    const Type = enum {
        fragment,
        vertex,
    };

    fragment_source: [:0]const u8,
    vertex_source: [:0]const u8,

    pub fn fromSources(fragment_source: [:0]const u8, vertex_source: [:0]const u8) Self {
        return .{
            .fragment_source = fragment_source,
            .vertex_source = vertex_source,
        };
    }

    fn compileSingle(self: Self, comptime type_: Type, report: ?*std.ArrayList(u8)) !nat.GLuint {
        const gl_type = switch (type_) {
            .fragment => nat.GL_FRAGMENT_SHADER,
            .vertex => nat.GL_VERTEX_SHADER,
        };

        const source = switch (type_) {
            .fragment => self.fragment_source,
            .vertex => self.vertex_source,
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

                try report_.ensureTotalCapacity(@intCast(max_len));
                report_.expandToCapacity();

                nat.glGetShaderInfoLog(shader, max_len, &max_len, @ptrCast(report_.items));
            }

            return error.CouldNotCompileShader;
        }

        return shader;
    }

    pub fn compile(self: Self) !CompiledShader {
        const fragment_shader = try self.compileSingle(.fragment, null);
        const vertex_shader = try self.compileSingle(.vertex, null);

        return .{
            .fragment_shader = fragment_shader,
            .vertex_shader = vertex_shader,
        };
    }
};
