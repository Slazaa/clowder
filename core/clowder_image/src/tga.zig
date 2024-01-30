const std = @import("std");

const root = @import("root.zig");

pub fn load(allocator: std.mem.Allocator, reader: std.fs.File.Reader) !root.Image {
    var image = root.Image.init(allocator);
    errdefer image.deinit();

    try reader.skipBytes(12, .{});

    image.size[0] = try reader.readInt(u16, .little);
    image.size[1] = try reader.readInt(u16, .little);

    try reader.skipBytes(2, .{});

    const byte_count = image.size[0] * image.size[1] * 4;

    try image.data.resize(byte_count);

    var buffer: [4]u8 = undefined;
    var i: usize = 0;

    var buffered_reader = std.io.bufferedReader(reader);
    const buffered_reader_reader = buffered_reader.reader();

    while (i != byte_count) : (i += buffer.len) {
        _ = try buffered_reader_reader.readAll(&buffer);
        try image.data.appendSlice(&.{ buffer[2], buffer[1], buffer[0], buffer[3] });
    }

    return image;
}
