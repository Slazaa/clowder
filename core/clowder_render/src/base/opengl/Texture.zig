const image_ = @import("clowder_image");

const nat = @import("../../native/opengl.zig");

const Self = @This();

native: nat.GLuint,

pub fn initFromImage(image: image_.Image) Self {
    var native: nat.GLuint = undefined;

    nat.glGenTextures(1, &native);
    nat.glActiveTexture(nat.GL_TEXTURE0);
    nat.glBindTexture(nat.GL_TEXTURE_2D, native);

    nat.glTexParameteri(nat.GL_TEXTURE_2D, nat.GL_TEXTURE_MIN_FILTER, nat.GL_NEAREST);
    nat.glTexParameteri(nat.GL_TEXTURE_2D, nat.GL_TEXTURE_MAG_FILTER, nat.GL_NEAREST);

    nat.glTexParameteri(nat.GL_TEXTURE_2D, nat.GL_TEXTURE_WRAP_S, nat.GL_REPEAT);
    nat.glTexParameteri(nat.GL_TEXTURE_2D, nat.GL_TEXTURE_WRAP_T, nat.GL_REPEAT);

    nat.glTexImage2D(
        nat.GL_TEXTURE_2D,
        0,
        nat.GL_RGBA,
        image.size[0],
        image.size[1],
        0,
        nat.GL_RGBA,
        nat.GL_UNSIGNED_BYTE,
        image.data.items,
    );
}
