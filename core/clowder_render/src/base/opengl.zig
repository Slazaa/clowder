const builtin = @import("builtin");
const std = @import("std");

const math = @import("clowder_math");

const nat = @import("../native/opengl.zig");

const Color = @import("../Color.zig");

pub const RenderObject = struct {
    const Self = @This();

    position_vbo: nat.GLuint,
    color_vbo: nat.GLuint,

    vertices_count: usize,

    vao: nat.GLuint,
    ibo: nat.GLuint,

    fn initBufferObject(comptime T: type, target: nat.GLenum, data: []const T) nat.GLuint {
        var buffer_object: nat.GLuint = undefined;

        nat.glGenBuffers(1, @ptrCast(&buffer_object));
        nat.glBindBuffer(target, buffer_object);

        nat.glBufferData(
            target,
            @intCast(@sizeOf(T) * data.len),
            @ptrCast(data),
            nat.GL_STATIC_DRAW,
        );

        return buffer_object;
    }

    pub fn init(positions: []const f32, colors: []const f32, indicies: []const u32) Self {
        var vao: nat.GLuint = undefined;

        nat.glGenVertexArrays(1, @ptrCast(&vao));
        nat.glBindVertexArray(vao);

        const position_vbo = initBufferObject(f32, nat.GL_ARRAY_BUFFER, positions);

        nat.glEnableVertexAttribArray(@intCast(0));
        nat.glVertexAttribPointer(0, 3, nat.GL_FLOAT, nat.GL_FALSE, 0, null);

        const color_vbo = initBufferObject(f32, nat.GL_ARRAY_BUFFER, colors);

        nat.glEnableVertexAttribArray(1);
        nat.glVertexAttribPointer(1, 4, nat.GL_FLOAT, nat.GL_FALSE, 0, null);

        const ibo = initBufferObject(u32, nat.GL_ELEMENT_ARRAY_BUFFER, indicies);

        return .{
            .position_vbo = position_vbo,
            .color_vbo = color_vbo,

            .vertices_count = positions.len,

            .vao = vao,
            .ibo = ibo,
        };
    }
};

pub fn initShader(type_: nat.GLuint, source: [:0]const u8, report: ?*std.ArrayList(u8)) !nat.GLuint {
    const shader = nat.glCreateShader(type_);
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

pub fn initShaderProgram(
    vert_source: [:0]const u8,
    frag_source: [:0]const u8,
    shader_report: ?*std.ArrayList(u8),
) !nat.GLuint {
    const shader_program = nat.glCreateProgram();

    const vert_shader = try initShader(nat.GL_VERTEX_SHADER, vert_source, shader_report);
    const frag_shader = try initShader(nat.GL_FRAGMENT_SHADER, frag_source, shader_report);

    nat.glAttachShader(shader_program, vert_shader);
    nat.glAttachShader(shader_program, frag_shader);

    nat.glLinkProgram(shader_program);
    nat.glValidateProgram(shader_program);

    return shader_program;
}

pub fn clear(color: Color, window_size: math.Vec2u) void {
    nat.glViewport(0, 0, @intCast(window_size[0]), @intCast(window_size[1]));

    nat.glClearColor(color.red, color.green, color.blue, color.alpha);
    nat.glClear(nat.GL_COLOR_BUFFER_BIT | nat.GL_DEPTH_BUFFER_BIT | nat.GL_STENCIL_BUFFER_BIT);
}

pub fn render(render_object: RenderObject) void {
    nat.glBindVertexArray(render_object.position_vbo);
    nat.glDrawElements(nat.GL_TRIANGLES, @intCast(render_object.vertices_count), nat.GL_UNSIGNED_INT, null);
}
