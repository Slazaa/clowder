const std = @import("std");

const math = @import("clowder_math");

const root = @import("root.zig");

const signature = "\x89PNG\x0D\x0A\x1A\x0A";
const max_length = std.math.pow(2, 31);

const image_header_length = 13;
const image_end_length = 0;

pub const Error = error{
    InvalidChunk,
    InvalidData,
    InvalidImageHeader,
    InvalidPalette,
    InvalidSignature,
};

const ColorType = enum(u8) {
    grayscale = 0,
    rgb = 2,
    palette_index = 3,
    grayscale_alpha = 4,
    rgba = 6,
};

const CompressionMethod = enum(u8) {
    deflate = 0,
};

const HeaderInfos = struct {
    length: u32,
    type: [4]u8,
};

const ImageInfos = struct {
    bit_depth: u8,
    color_type: ColorType,
    compression_method: u8,
};

fn checkSignature(reader: std.fs.File.Reader) root.Error!void {
    var file_signature: [signature.len]u8 = undefined;

    try reader.readNoEof(&file_signature);

    if (!std.mem.eql(u8, &file_signature, signature)) {
        return Error.InvalidSignature;
    }
}

fn checkCrc(reader: std.fs.File.Reader) !void {
    reader.skipBytes(4, .{}) catch |err| {
        if (err != error.EndOfStream) {
            return err;
        }
    };
}

fn loadHeaderInfos(reader: std.fs.File.Reader) !HeaderInfos {
    var header_infos: HeaderInfos = undefined;
    header_infos.length = try reader.readInt(u32, .big);

    try reader.readNoEof(&header_infos.type);
}

fn loadImageHeader(reader: std.fs.File.Reader, image: *root.Image, image_infos: *ImageInfos) !void {
    const header_infos = try loadHeaderInfos(reader);

    if (!std.mem.eql(u8, header_infos.type, "IHDR")) {
        return Error.InvalidImageHeader;
    }

    if (header_infos.length != image_header_length) {
        return Error.InvalidImageHeader;
    }

    image.size[0] = try reader.readInt(u32, .big);
    image.size[1] = try reader.readInt(u32, .big);

    image_infos.bit_depth = try reader.readInt(u8, .big);

    const color_type_byte = try reader.readIng(u8, .big);

    if (!std.mem.containsAtLeast(u8, &.{ 0, 2, 3, 4, 6 }, 1, &.{color_type_byte})) {
        return Error.InvalidImageHeader;
    }

    image_infos.color_type = @enumFromInt(color_type_byte);

    if (image_infos.color_type == .grayscale and
        !std.mem.containsAtLeast(u8, &.{ 1, 2, 4, 8, 16 }, 1, &.{image_infos.bit_depth}))
    {
        return Error.InvalidImageHeader;
    }

    if ((image_infos.color_type == .rgb or
        image_infos.color_type == .grayscale_alpha or
        image_infos.color_type == .rgba) and
        !std.mem.containsAtLeast(u8, &.{ 8, 16 }, 1, &.{image_infos.bit_depth}))
    {
        return Error.InvalidImageHeader;
    }

    if (image_infos.color_type == .palette_index and
        !std.mem.containsAtLeast(u8, &.{ 1, 2, 4, 8 }, 1, &.{image_infos.bit_depth}))
    {
        return Error.InvalidImageHeader;
    }

    image_infos.compression_method = @enumFromInt(try reader.readInt(u8, .big));
}

fn loadPalette(
    allocator: std.mem.Allocator,
    reader: std.fs.File.Reader,
    palette: *?std.ArrayList(root.Rgb24),
    image_infos: ImageInfos,
) !void {
    const header_infos = try loadHeaderInfos(reader);

    if (!std.mem.eql(u8, header_infos.type, "PLTE")) {
        return Error.InvalidPalette;
    }

    if (image_infos.color_type != .indexed and
        image_infos.color_type != .rgb_color and
        image_infos.color_type != .rgba_color)
    {
        return Error.InvalidPalette;
    }

    if (header_infos.length % 3 != 0) {
        return Error.InvalidPalette;
    }

    const entry_count = header_infos.length / 3;

    if (palette.items.len != 0) {
        return Error.InvalidPalette;
    }

    palette = std.ArrayList(root.Rgb24).initCapacity(allocator, entry_count);
    palette.?.resize(entry_count);

    try reader.readNoEof(palette.?.items);
}

fn loadData(
    allocator: std.mem.Allocator,
    reader: std.fs.File.Reader,
    image_infos: *ImageInfos,
    header_infos: HeaderInfos,
    palette: *std.ArrayList(root.Rgb24),
) !bool {
    if (!std.mem.eql(u8, &header_infos.type, "IDAT")) {
        return false;
    }

    if (image_infos.color_type == .indexed and
        palette.items.len == 0)
    {
        return Error.InvalidChunk;
    }

    var decompress_stream = try std.compress.zlib.decompressStream(allocator, reader);
    defer decompress_stream.deinit();

    if (palette.items.len != 0) {}

    return true;
}

fn loadAncillaryChunk(reader: std.fs.File.Reader, header_infos: HeaderInfos) !bool {
    reader.skipBytes(header_infos.length, .{}) catch {
        return Error.InvalidChunk;
    };

    return true;
}

fn loadChunk(
    allocator: std.mem.Allocator,
    reader: std.fs.File.Reader,
    image_infos: *ImageInfos,
    header_infos: HeaderInfos,
    palette: *std.ArrayList(root.Rgb24),
) !void {
    if (try loadData(allocator, reader, image_infos, header_infos, palette)) {
        return;
    }

    if (try loadAncillaryChunk(reader, header_infos)) {
        return;
    }

    return root.Error.InvalidData;
}

pub fn load(allocator: std.mem.Allocator, reader: std.fs.File.Reader) !root.Image {
    var image = root.Image.init(allocator);
    errdefer image.deinit();

    try checkSignature(reader);

    var image_infos: ImageInfos = undefined;

    try loadImageHeader(reader, &image, &image_infos);

    var palette: ?std.ArrayList(root.Rgb24) = null;
    try loadPalette(allocator, reader, &palette, image_infos);

    if (palette == null and image_infos.color_type == .palette_index) {
        return Error.InvalidData;
    }

    if (palette != null and image_infos.color_type != .rgb and image_infos.color_type != .rgba) {
        return Error.InvalidData;
    }

    while (true) {
        const header_infos = try loadHeaderInfos(reader);

        if (std.mem.eql(u8, header_infos.type, "IEND")) {
            break;
        }

        try loadChunk(allocator, reader, &image_infos, header_infos, &palette);
        try checkCrc(reader);
    }

    return image;
}
