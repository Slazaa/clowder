const image_ = @import("clowder_image");

const nat = @import("../../native/opengl.zig");

const Self = @This();

pub const FilterType = enum {
    nearest,
    linear,
};

native: nat.GLuint,

pub fn initFromImage(image: image_.Image, filter_type: FilterType) Self {
    var native: nat.GLuint = undefined;

    nat.glGenTextures(1, @ptrCast(&native));
    nat.glActiveTexture(nat.GL_TEXTURE0);
    nat.glBindTexture(nat.GL_TEXTURE_2D, native);

    const native_filter_type: nat.GLint = switch (filter_type) {
        .nearest => nat.GL_NEAREST,
        .linear => nat.GL_LINEAR,
    };

    nat.glTexParameteri(nat.GL_TEXTURE_2D, nat.GL_TEXTURE_MIN_FILTER, native_filter_type);
    nat.glTexParameteri(nat.GL_TEXTURE_2D, nat.GL_TEXTURE_MAG_FILTER, native_filter_type);

    nat.glTexParameteri(nat.GL_TEXTURE_2D, nat.GL_TEXTURE_WRAP_S, nat.GL_REPEAT);
    nat.glTexParameteri(nat.GL_TEXTURE_2D, nat.GL_TEXTURE_WRAP_T, nat.GL_REPEAT);

    nat.glTexImage2D(
        nat.GL_TEXTURE_2D,
        0,
        nat.GL_RGBA,
        @intCast(image.size[0]),
        @intCast(image.size[1]),
        0,
        nat.GL_RGBA,
        nat.GL_UNSIGNED_BYTE,
        @ptrCast(image.data.items),
    );

    return .{
        .native = native,
    };
}
