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
    rgb_color = 2,
    palette_index = 3,
    grayscale_alpha = 4,
    rgba_color = 6,
};

const CompressionMethod = enum(u8) {
    deflate = 0,
};

const FilterMethod = enum(u8) {
    adaptive = 0,
};

const InterlaceMethod = enum(u8) {
    none = 0,
    adam7 = 1,
};

const HeaderInfos = struct {
    length: u32,
    type: [4]u8,
};

const ImageInfos = struct {
    width: u32,
    height: u32,
    bit_depth: u8,
    color_type: ColorType,
    compression_method: CompressionMethod,
    filter_method: FilterMethod,
    interlace_method: InterlaceMethod,
};

const AdaptiveFilterType = enum(u8) {
    none = 0,
    sub = 1,
    up = 2,
    average = 3,
    paeth = 4,
};

fn checkSignature(reader: std.fs.File.Reader) !void {
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

    std.debug.print("Type: {s}\n", .{header_infos.type});
    std.debug.print("Len: {}\n", .{header_infos.length});

    return header_infos;
}

fn loadImageHeader(reader: std.fs.File.Reader, image_infos: *ImageInfos) !void {
    const header_infos = try loadHeaderInfos(reader);

    if (!std.mem.eql(u8, &header_infos.type, "IHDR")) {
        return Error.InvalidImageHeader;
    }

    if (header_infos.length != image_header_length) {
        return Error.InvalidImageHeader;
    }

    // Size
    image_infos.width = try reader.readInt(u32, .big);
    image_infos.height = try reader.readInt(u32, .big);

    // Bit depth
    image_infos.bit_depth = try reader.readInt(u8, .big);

    // Color type
    const color_type_byte = try reader.readInt(u8, .big);

    if (!std.mem.containsAtLeast(u8, &.{ 0, 2, 3, 4, 6 }, 1, &.{color_type_byte})) {
        return Error.InvalidImageHeader;
    }

    image_infos.color_type = @enumFromInt(color_type_byte);

    if (image_infos.color_type == .grayscale and
        !std.mem.containsAtLeast(u8, &.{ 1, 2, 4, 8, 16 }, 1, &.{image_infos.bit_depth}))
    {
        return Error.InvalidImageHeader;
    }

    if ((image_infos.color_type == .rgb_color or
        image_infos.color_type == .grayscale_alpha or
        image_infos.color_type == .rgba_color) and
        !std.mem.containsAtLeast(u8, &.{ 8, 16 }, 1, &.{image_infos.bit_depth}))
    {
        return Error.InvalidImageHeader;
    }

    if (image_infos.color_type == .palette_index and
        !std.mem.containsAtLeast(u8, &.{ 1, 2, 4, 8 }, 1, &.{image_infos.bit_depth}))
    {
        return Error.InvalidImageHeader;
    }

    // Compression method
    const compression_method_byte = try reader.readInt(u8, .big);

    if (compression_method_byte != 0) {
        return Error.InvalidImageHeader;
    }

    image_infos.compression_method = @enumFromInt(compression_method_byte);

    // Filter method
    const filter_method_byte = try reader.readInt(u8, .big);

    if (filter_method_byte != 0) {
        return Error.InvalidImageHeader;
    }

    image_infos.filter_method = @enumFromInt(filter_method_byte);

    // Interlace method
    const interlace_method_byte = try reader.readInt(u8, .big);

    if (interlace_method_byte != 0 and interlace_method_byte != 1) {
        return Error.InvalidImageHeader;
    }

    image_infos.interlace_method = @enumFromInt(interlace_method_byte);

    // CRC
    try checkCrc(reader);
}

fn loadPalette(
    allocator: std.mem.Allocator,
    reader: std.fs.File.Reader,
    header_infos: HeaderInfos,
    palette: *?std.ArrayList(root.Rgb24),
    image_infos: ImageInfos,
) !bool {
    if (!std.mem.eql(u8, &header_infos.type, "PLTE")) {
        return false;
    }

    if (image_infos.color_type != .palette_index and
        image_infos.color_type != .rgb_color and
        image_infos.color_type != .rgba_color)
    {
        return Error.InvalidPalette;
    }

    if (header_infos.length % 3 != 0) {
        return Error.InvalidPalette;
    }

    const entry_count = header_infos.length / 3;

    if (entry_count > std.math.pow(u32, 2, image_infos.bit_depth)) {
        return Error.InvalidPalette;
    }

    palette.* = try std.ArrayList(root.Rgb24).initCapacity(allocator, entry_count);
    try palette.*.?.resize(entry_count);

    for (0..entry_count) |i| {
        var buffer: [3]u8 = undefined;
        try reader.readNoEof(&buffer);

        palette.*.?.items[i].r = buffer[0];
        palette.*.?.items[i].g = buffer[1];
        palette.*.?.items[i].b = buffer[2];
    }

    return true;
}

fn loadData(
    allocator: std.mem.Allocator,
    reader: std.fs.File.Reader,
    header_infos: HeaderInfos,
    palette: *?std.ArrayList(root.Rgb24),
    image_infos: ImageInfos,
) !bool {
    if (!std.mem.eql(u8, &header_infos.type, "IDAT")) {
        return false;
    }

    if (palette.* == null and image_infos.color_type == .palette_index) {
        return Error.InvalidData;
    }

    if (palette.* != null and
        !std.mem.containsAtLeast(
        ColorType,
        .{ .palette_index, .rgb_color, .rgba_color },
        1,
        &.{image_infos.color_type},
    )) {
        return Error.InvalidData;
    }

    var decompress_stream = try std.compress.zlib.decompressStream(allocator, reader);
    defer decompress_stream.deinit();

    if (image_infos.interlace_method != .none) {
        @panic("Not implemented yet");
    }

    if (image_infos.filter_method != .adaptive) {
        @panic("Not implemented yet");
    }

    const filter_type_byte = try reader.readInt(u8, .big);

    if (!std.mem.containsAtLeast(u8, &.{ 0, 1, 2, 3, 4 }, 1, &.{filter_type_byte})) {
        return Error.InvalidData;
    }

    const filter_type: AdaptiveFilterType = @enumFromInt(filter_type_byte);
    _ = filter_type;

    return true;
}

fn loadAncillaryChunk(reader: std.fs.File.Reader, header_infos: HeaderInfos) !bool {
    reader.skipBytes(header_infos.length, .{}) catch {
        return Error.InvalidData;
    };

    return true;
}

fn loadChunk(
    allocator: std.mem.Allocator,
    reader: std.fs.File.Reader,
    header_infos: HeaderInfos,
    palette: *?std.ArrayList(root.Rgb24),
    image_infos: ImageInfos,
) !void {
    if (try loadPalette(allocator, reader, header_infos, palette, image_infos)) {
        return;
    }

    if (try loadData(allocator, reader, header_infos, palette, image_infos)) {
        return;
    }

    if (try loadAncillaryChunk(reader, header_infos)) {
        return;
    }

    return Error.InvalidChunk;
}

pub fn load(allocator: std.mem.Allocator, reader: std.fs.File.Reader) !root.Image {
    var image = root.Image.init(allocator);
    errdefer image.deinit();

    try checkSignature(reader);

    var image_infos: ImageInfos = undefined;

    try loadImageHeader(reader, &image_infos);

    image.size = .{ image_infos.width, image_infos.height };

    var palette: ?std.ArrayList(root.Rgb24) = null;

    errdefer {
        if (palette) |palette_| {
            palette_.deinit();
        }
    }

    while (true) {
        const header_infos = try loadHeaderInfos(reader);

        if (std.mem.eql(u8, &header_infos.type, "IEND")) {
            break;
        }

        try loadChunk(allocator, reader, header_infos, &palette, image_infos);
        try checkCrc(reader);
    }

    return image;
}
