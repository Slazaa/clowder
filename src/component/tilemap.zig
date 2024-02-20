const std = @import("std");

const root = @import("../root.zig");

pub fn Tilemap(comptime config: root.RendererConfig) type {
    return struct {
        const Self = @This();

        const Sprite = root.bundle.Sprite(config);

        tiles: std.ArrayList(?Sprite),
        tile_size: root.Vec2f,
        size: root.Vec2u,

        pub fn init(allocator: std.mem.Allocator, tile_size: root.Vec2f, size: root.Vec2u) !Self {
            var tiles = try std.ArrayList(?Sprite).initCapacity(allocator, size[0] * size[1]);
            errdefer tiles.deinit();

            try tiles.appendNTimes(null, size[0] * size[1]);

            return .{
                .tiles = tiles,
                .tile_size = tile_size,
                .size = size,
            };
        }

        pub fn deinit(self: Self) void {
            for (self.tiles.items) |maybe_sprite| {
                const sprite = maybe_sprite orelse continue;
                sprite.deinit();
            }

            self.tiles.deinit();
        }

        fn indexFromPos(self: Self, position: root.Vec2u) !usize {
            const index = self.size[0] * position[1] + position[0];

            if (index >= self.tiles.items.len) {
                return error.InvalidPosition;
            }

            return index;
        }

        pub inline fn set(self: Self, position: root.Vec2u, sprite: Sprite) !void {
            const index = try self.indexFromPos(position);
            self.tiles.items[index] = sprite;
        }
    };
}
