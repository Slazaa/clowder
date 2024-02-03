const std = @import("std");

const image_ = @import("clowder_image");
const math = @import("clowder_math");

const nat = @import("../../native/opengl.zig");

const Self = @This();

pub const FilterType = enum {
    nearest,
    linear,
};

native: nat.GLuint,
size: math.Vec2u,

pub fn initRaw(data: []const u8, size: math.Vec2u, filter_type: FilterType) Self {
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
        @intCast(size[0]),
        @intCast(size[1]),
        0,
        nat.GL_RGBA,
        nat.GL_UNSIGNED_BYTE,
        @ptrCast(data),
    );

    return .{
        .native = native,
        .size = size,
    };
}

pub fn initFromImage(image: image_.Image, filter_type: FilterType) Self {
    return initRaw(image.data.items, image.size, filter_type);
}

pub fn default() Self {
    return initRaw(&(.{std.math.maxInt(u8)} ** 4), .{ 1, 1 }, .nearest);
}
