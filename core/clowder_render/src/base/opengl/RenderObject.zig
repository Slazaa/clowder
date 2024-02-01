const nat = @import("../../native/opengl.zig");

const Texture = @import("Texture.zig");

const Self = @This();

position_vbo: nat.GLuint,
color_vbo: nat.GLuint,
uv_coord_vbo: nat.GLuint,

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

pub fn init(
    positions: []const f32,
    colors: []const f32,
    uv_coords: []const f32,
    indicies: []const u32,
) Self {
    var vao: nat.GLuint = undefined;

    nat.glGenVertexArrays(1, @ptrCast(&vao));
    nat.glBindVertexArray(vao);

    // Positions
    const position_vbo = initBufferObject(f32, nat.GL_ARRAY_BUFFER, positions);

    nat.glEnableVertexAttribArray(@intCast(0));
    nat.glVertexAttribPointer(0, 3, nat.GL_FLOAT, nat.GL_FALSE, 0, null);

    // Colors
    const color_vbo = initBufferObject(f32, nat.GL_ARRAY_BUFFER, colors);

    nat.glEnableVertexAttribArray(1);
    nat.glVertexAttribPointer(1, 4, nat.GL_FLOAT, nat.GL_FALSE, 0, null);

    // UV coords
    const uv_coord_vbo = initBufferObject(f32, nat.GL_ARRAY_BUFFER, uv_coords);

    nat.glEnableVertexAttribArray(2);
    nat.glVertexAttribPointer(2, 2, nat.GL_FLOAT, nat.GL_FALSE, 0, null);

    // Indices
    const ibo = initBufferObject(u32, nat.GL_ELEMENT_ARRAY_BUFFER, indicies);

    return .{
        .position_vbo = position_vbo,
        .color_vbo = color_vbo,
        .uv_coord_vbo = uv_coord_vbo,

        .vertices_count = positions.len,

        .vao = vao,
        .ibo = ibo,
    };
}
