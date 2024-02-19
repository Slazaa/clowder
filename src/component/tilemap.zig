const std = @import("std");

const root = @import("../root.zig");

pub fn Tilemap(comptime config: root.RendererConfig) type {
    return struct {
        const Self = @This();

        const Sprite = root.bundle.Sprite(config);

        tiles: std.ArrayList(?Sprite),
        tile_size: root.Vec2f,
        size: root.Vec2f,

        pub fn init(allocator: std.mem.Allocator, tile_size: root.Vec2f, size: root.Vec2f) !Self {
            const tiles = try std.ArrayList(Sprite).initCapacity(allocator, size[0] * size[1]);
            errdefer tiles.deinit();

            try tiles.appendNTimes(null, size[0] * size[1]);

            return .{
                .tiles = tiles,
                .tile_size = tile_size,
                .size = size,
            };
        }

        pub fn deinit(self: Self) void {
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

        pub inline fn get(self: Self, position: root.Vec2u) !?Sprite {
            const index = try self.indexFromPos(position);
            return self.tiles.items[index];
        }
    };
}
