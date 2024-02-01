const std = @import("std");

const root = @import("root.zig");

pub const Error = error{
    InvalidHeader,
};

const ColorMapType = enum(u8) {
    none = 0,
    present = 1,
};

const Header = struct {
    id_length: u8,
    color_map_type: ColorMapType,
    image_type: u8,

    // Color map specifictions.
    map_first_entry: u16,
    map_length: u16,
    map_entry_size: u8,

    // Image specifictions.
    image_x_origin: u16,
    image_y_origin: u16,
    image_width: u16,
    image_height: u16,
    pixel_depth: u8,
    image_descriptor: u8,
};

fn loadHeader(reader: std.fs.File.Reader) !Header {
    const id_length = try reader.readInt(u8, .big);

    const color_map_type = blk: {
        const color_map_type_byte = try reader.readInt(u8, .big);

        if (color_map_type_byte != 0 and color_map_type_byte != 1) {
            return Error.InvalidHeader;
        }

        break :blk @as(ColorMapType, @enumFromInt(color_map_type_byte));
    };

    const image_type = try reader.readInt(u8, .big);

    const map_first_entry = try reader.readInt(u16, .little);
    const map_length = try reader.readInt(u16, .little);
    const map_entry_size = try reader.readInt(u8, .big);

    const image_x_origin = try reader.readInt(u16, .little);
    const image_y_origin = try reader.readInt(u16, .little);
    const image_width = try reader.readInt(u16, .little);
    const image_height = try reader.readInt(u16, .little);
    const pixel_depth = try reader.readInt(u8, .big);
    const image_descriptor = try reader.readInt(u8, .big);

    return .{
        .id_length = id_length,
        .color_map_type = color_map_type,
        .image_type = image_type,

        .map_first_entry = map_first_entry,
        .map_length = map_length,
        .map_entry_size = map_entry_size,

        .image_x_origin = image_x_origin,
        .image_y_origin = image_y_origin,
        .image_width = image_width,
        .image_height = image_height,
        .pixel_depth = pixel_depth,
        .image_descriptor = image_descriptor,
    };
}

pub fn load(allocator: std.mem.Allocator, reader: std.fs.File.Reader) !root.Image {
    var image = root.Image.init(allocator);
    errdefer image.deinit();

    const header = try loadHeader(reader);

    image.size[0] = header.image_width;
    image.size[1] = header.image_height;

    try reader.skipBytes(header.id_length, .{});

    const byte_count = image.size[0] * image.size[1] * 4;

    try image.data.ensureTotalCapacity(byte_count);

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
