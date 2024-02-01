const render = @import("clowder_render");

pub fn Sprite(comptime backend: render.Backend) type {
    return struct {
        const Self = @This();

        const Texture = render.Texture(backend);

        texture: Texture,

        pub fn init(texture: render.Texture) Self {
            return .{
                .texture = texture,
            };
        }
    };
}
