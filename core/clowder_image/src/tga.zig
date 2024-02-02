const std = @import("std");

const root = @import("root.zig");

pub const Error = error{
    InvalidHeader,
};

const ColorMapType = enum(u8) {
    none = 0,
    present = 1,
};

const ImageType = enum(u8) {
    const Self = @This();

    none = 0,
    color_mapped = 1,
    true_color = 2,
    grayscale = 3,
    rle_color_mapped = 9,
    rle_true_color = 10,
    rle_grayscale = 11,

    pub fn isColorMapped(self: Self) bool {
        return switch (self) {
            .color_mapped, .rle_color_mapped => true,
            else => false,
        };
    }

    pub fn isTrueColor(self: Self) bool {
        return switch (self) {
            .true_color, .rle_true_color => true,
            else => false,
        };
    }

    pub fn isGrayscale(self: Self) bool {
        return switch (self) {
            .grayscale, .rle_grayscale => true,
            else => false,
        };
    }

    pub fn isRle(self: Self) bool {
        return switch (self) {
            .rle_color_mapped, .rle_true_color, .rle_grayscale => true,
            else => false,
        };
    }
};

const Header = packed struct {
    const Self = @This();

    id_length: u8,
    color_map_type: ColorMapType,
    image_type: ImageType,

    // Color map specifictions.
    color_map_first_entry: u16,
    color_map_length: u16,
    color_map_entry_size: u8,

    // Image specifictions.
    image_x_origin: u16,
    image_y_origin: u16,
    image_width: u16,
    image_height: u16,
    pixel_depth: u8,
    image_descriptor: u8,
};

const PixelFormat = enum {
    const Self = @This();

    bw8,
    bw16,

    rgb555,
    rgb24,
    rgba32,

    pub fn initFromHeader(header: Header) !Self {
        if (header.image_type.isColorMapped()) {
            switch (header.color_map_entry_size) {
                15, 16 => return .rgb555,
                24 => return .rgb24,
                32 => return .rgba32,
                else => {},
            }
        } else if (header.image_type.isTrueColor()) {
            switch (header.pixel_depth) {
                16 => return .rgb555,
                24 => return .rgb24,
                32 => return .rgba32,
                else => {},
            }
        } else if (header.image_type.isGrayscale()) {
            switch (header.pixel_depth) {
                8 => return .bw8,
                16 => return .bw16,
                else => {},
            }
        }

        return error.InvalidHeader;
    }

    pub fn toPixelSize(self: Self) u8 {
        return switch (self) {
            .bw8 => 1,
            .bw16, .rgb555 => 2,
            .rgb24 => 3,
            .rgba32 => 4,
        };
    }
};

fn loadHeader(reader: std.fs.File.Reader) !Header {
    return .{
        .id_length = try reader.readInt(u8, .big),
        .color_map_type = try reader.readEnum(ColorMapType, .big),
        .image_type = try reader.readEnum(ImageType, .big),

        .color_map_first_entry = try reader.readInt(u16, .little),
        .color_map_length = try reader.readInt(u16, .little),
        .color_map_entry_size = try reader.readInt(u8, .big),

        .image_x_origin = try reader.readInt(u16, .little),
        .image_y_origin = try reader.readInt(u16, .little),
        .image_width = try reader.readInt(u16, .little),
        .image_height = try reader.readInt(u16, .little),
        .pixel_depth = try reader.readInt(u8, .big),
        .image_descriptor = try reader.readInt(u8, .big),
    };
}

fn decodeRle(
    reader: std.fs.File.Reader,
    data: *std.ArrayList(u8),
    pixel_count: usize,
    pixel_format: PixelFormat,
) !void {
    var pixel_counter = pixel_count;

    const pixel_size = pixel_format.toPixelSize();

    while (pixel_counter > 0) {
        const rep_count = try reader.readInt(u8, .big) + 1;

        var pixel: [4]u8 = undefined;

        for (0..pixel_size) |i| {
            pixel[i] = try reader.readInt(u8, .big);
        }

        for (0..rep_count) |_| {
            try data.appendSlice(pixel[0..pixel_size]);
        }

        pixel_counter -= rep_count;
    }
}

pub fn load(allocator: std.mem.Allocator, reader: std.fs.File.Reader) !root.Image {
    var image = root.Image.init(allocator);
    errdefer image.deinit();

    const header = try loadHeader(reader);

    if (header.color_map_entry_size % 8 != 0) {
        return Error.InvalidHeader;
    }

    image.size[0] = header.image_width;
    image.size[1] = header.image_height;

    const pixel_format = try PixelFormat.initFromHeader(header);

    var buffered_reader = std.io.bufferedReader(reader);
    var buffered_reader_reader = buffered_reader.reader();

    // Skip image ID.
    try buffered_reader_reader.skipBytes(header.id_length, .{});

    // Skip color map data.
    try buffered_reader_reader.skipBytes(header.color_map_entry_size / 8 * header.color_map_length, .{});

    // Image data.
    const pixel_count = image.size[0] * image.size[1];

    if (header.image_type.isRle()) {
        try decodeRle(reader, &image.data, pixel_count, pixel_format);
    } else {
        try image.data.resize(pixel_count * 4);
        _ = try buffered_reader_reader.readAll(image.data.items);
    }

    return image;
}
