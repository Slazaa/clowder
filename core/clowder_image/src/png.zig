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
    InvalidCrc,
};

const ColorType = enum(u8) {
    grayscale = 0,
    rgb = 2,
    indexed = 3,
    grayscale_alpha = 4,
    rgba = 6,
};

const CompressionMethod = enum(u8) {
    deflate = 0,
};

const FilterMethod = enum(u8) {
    adaptive = 0,
};

const Filter = enum(u8) {
    none = 0,
    sub = 1,
    up = 2,
    average = 3,
    paeth = 4,
};

const InterlaceMethod = enum(u8) {
    none = 0,
    adam7 = 1,
};

const ChunkType = blk: {
    const field_names = .{
        // Critical
        "IHDR",
        "PLTE",
        "IDAT",
        "IEND",

        // Ancillary
        "tRNS",
        "cHRM",
        "gAMA",
        "iCCP",
        "sBIT",
        "sRGB",
        "tEXt",
        "zTXt",
        "iTXt",
        "bKGD",
        "hIST",
        "pHYs",
        "sPLT",
        "tIME",
    };

    var fields: []const std.builtin.Type.EnumField = &.{};

    for (field_names) |field_name| {
        fields = fields ++ @as([]const std.builtin.Type.EnumField, &.{.{
            .name = field_name,
            .value = std.mem.bytesToValue(u32, field_name),
        }});
    }

    break :blk @Type(std.builtin.Type{
        .Enum = .{
            .tag_type = u32,
            .fields = fields,
            .decls = &.{},
            .is_exhaustive = false,
        },
    });
};

const ChunkHeader = struct {
    const Self = @This();

    length: u32,
    type: ChunkType,

    pub fn loadFromStream(stream: *std.io.StreamSource) !Self {
        const reader = stream.reader();

        const length = try reader.readInt(u32, .big);
        const type_ = try reader.readEnum(ChunkType, .little);

        return .{
            .length = length,
            .type = type_,
        };
    }
};

const ImageInfos = struct {
    const Self = @This();

    width: u32,
    height: u32,
    bit_depth: u8,
    color_type: ColorType,
    compression_method: CompressionMethod,
    filter_method: FilterMethod,
    interlace_method: InterlaceMethod,

    pub inline fn allowsPalette(self: Self) bool {
        return std.mem.containsAtLeast(ColorType, &.{ .indexed, .rgb, .rgba }, 1, &.{self.color_type});
    }
};

const AdaptiveFilterType = enum(u8) {
    none = 0,
    sub = 1,
    up = 2,
    average = 3,
    paeth = 4,
};

fn checkSignature(stream: *std.io.StreamSource) !void {
    const reader = stream.reader();

    var file_signature: [signature.len]u8 = undefined;
    try reader.readNoEof(&file_signature);

    if (!std.mem.eql(u8, &file_signature, signature)) {
        return Error.InvalidSignature;
    }
}

fn checkCrc(chunk_header: ChunkHeader, data: []const u8, expected: u32) !void {
    var crc = std.hash.Crc32.init();
    crc.update(&std.mem.toBytes(chunk_header.type));
    crc.update(data);

    if (crc.final() != expected) {
        return Error.InvalidCrc;
    }
}

fn loadHeader(stream: *std.io.StreamSource, image_infos: *ImageInfos) !void {
    const reader = stream.reader();

    // Size
    image_infos.width = try reader.readInt(u32, .big);
    image_infos.height = try reader.readInt(u32, .big);

    // Bit depth
    image_infos.bit_depth = try reader.readInt(u8, .big);

    // Color type
    image_infos.color_type = try reader.readEnum(ColorType, .big);

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

    if (image_infos.color_type == .indexed and
        !std.mem.containsAtLeast(u8, &.{ 1, 2, 4, 8 }, 1, &.{image_infos.bit_depth}))
    {
        return Error.InvalidImageHeader;
    }

    // Compression method
    image_infos.compression_method = try reader.readEnum(CompressionMethod, .big);

    // Filter method
    image_infos.filter_method = try reader.readEnum(FilterMethod, .big);

    // Interlace method
    image_infos.interlace_method = try reader.readEnum(InterlaceMethod, .big);
}

fn loadPalette(
    allocator: std.mem.Allocator,
    stream: *std.io.StreamSource,
    image_infos: ImageInfos,
    chunk_header: ChunkHeader,
    maybe_palette: *?std.ArrayList(root.Rgb24),
) !void {
    if (maybe_palette.* != null or
        !image_infos.allowsPalette() or
        chunk_header.length % 3 != 0)
    {
        return Error.InvalidPalette;
    }

    const length = chunk_header.length / 3;

    if (length > std.math.pow(u32, 2, image_infos.bit_depth)) {
        return Error.InvalidPalette;
    }

    var palette = try std.ArrayList(root.Rgb24).initCapacity(allocator, length);
    errdefer palette.deinit();

    palette.expandToCapacity();

    const reader = stream.reader();

    var buffer: [3]u8 = undefined;

    for (0..length) |i| {
        const byte_count = try reader.readAll(&buffer);

        if (byte_count == 0) {
            break;
        }

        if (byte_count != buffer.len) {
            return Error.InvalidPalette;
        }

        palette.items[i].red = buffer[0];
        palette.items[i].green = buffer[1];
        palette.items[i].blue = buffer[2];
    }

    maybe_palette.* = palette;
}

fn loadData(
    allocator: std.mem.Allocator,
    stream: *std.io.StreamSource,
    image_infos: ImageInfos,
    maybe_palette: ?std.ArrayList(root.Rgb24),
    image: *root.Image,
) !void {
    if (maybe_palette == null and image_infos.color_type == .indexed) {
        return Error.InvalidData;
    }

    if (maybe_palette != null and !image_infos.allowsPalette()) {
        return Error.InvalidData;
    }

    const reader = stream.reader();

    var temp_data = std.ArrayList(u8).init(allocator);
    defer temp_data.deinit();

    const temp_data_writer = temp_data.writer();

    try std.compress.zlib.decompress(reader, temp_data_writer);

    switch (image_infos.interlace_method) {
        .none => {},
        .adam7 => {},
    }

    try image.data.appendSlice(temp_data.items);
}

fn loadChunk(
    allocator: std.mem.Allocator,
    stream: *std.io.StreamSource,
    image_infos: *ImageInfos,
    chunk_header: ChunkHeader,
    maybe_palette: *?std.ArrayList(root.Rgb24),
    image: *root.Image,
) !void {
    switch (chunk_header.type) {
        .IHDR => try loadHeader(stream, image_infos),
        .PLTE => try loadPalette(allocator, stream, image_infos.*, chunk_header, maybe_palette),
        .IDAT => try loadData(allocator, stream, image_infos.*, maybe_palette.*, image),
        else => {},
    }
}

pub fn loadFromStream(allocator: std.mem.Allocator, stream: *std.io.StreamSource) !root.Image {
    try checkSignature(stream);

    var data = std.ArrayList(u8).init(allocator);
    defer data.deinit();

    var image = root.Image.init(allocator);
    errdefer image.deinit();

    var image_infos: ImageInfos = undefined;
    var maybe_palette: ?std.ArrayList(root.Rgb24) = null;

    defer {
        if (maybe_palette) |palette| {
            palette.deinit();
        }
    }

    const reader = stream.reader();

    while (true) {
        const chunk_header = try ChunkHeader.loadFromStream(stream);

        if (chunk_header.type == .IEND) {
            break;
        }

        data.clearRetainingCapacity();
        try data.resize(chunk_header.length);

        _ = try reader.readAll(data.items);

        const data_fixed_buffer = std.io.fixedBufferStream(@as([]const u8, data.items));
        var data_stream = std.io.StreamSource{ .const_buffer = data_fixed_buffer };

        try loadChunk(
            allocator,
            &data_stream,
            &image_infos,
            chunk_header,
            &maybe_palette,
            &image,
        );

        const expected_crc = try reader.readInt(u32, .big);

        try checkCrc(chunk_header, data.items, expected_crc);
    }

    image.size = .{ image_infos.width, image_infos.height };

    return image;
}
