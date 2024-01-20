const builtin = @import("builtin");
const std = @import("std");

const math = @import("clowder_math");

const nat = @import("../native/opengl.zig");

const Color = @import("../Color.zig");

pub const RenderObject = struct {
    const Self = @This();

    vertex_buffer_object: nat.GLuint,
    vertex_array_object: nat.GLuint,

    pub fn init(vertices: []const math.Vertex) Self {
        var vertex_arry_object: nat.GLuint = undefined;

        nat.glGenVertexArrays(1, @ptrCast(&vertex_arry_object));
        nat.glBindVertexArray(vertex_arry_object);

        var vertex_buffer_object: nat.GLuint = undefined;

        nat.glGenBuffers(1, @ptrCast(&vertex_buffer_object));
        nat.glBindBuffer(nat.GL_ARRAY_BUFFER, vertex_buffer_object);

        nat.glBufferData(
            nat.GL_ARRAY_BUFFER,
            @intCast(@sizeOf(math.Vertex) * vertices.len),
            @ptrCast(vertices),
            nat.GL_STATIC_DRAW,
        );

        nat.glEnableVertexAttribArray(0);
        nat.glVertexAttribPointer(0, 3, nat.GL_FLOAT, nat.GL_FALSE, 0, null);

        return .{
            .vertex_buffer_object = vertex_buffer_object,
            .vertex_array_object = vertex_arry_object,
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
    nat.glBindVertexArray(render_object.vertex_array_object);
    nat.glDrawArrays(nat.GL_TRIANGLES, 0, 3);
}
