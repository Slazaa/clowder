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

const FilterMethod = enum(u8) {
    adaptive = 0,
};

const InterlaceMethod = enum(u8) {
    none = 0,
    adam7 = 1,
};

const HeaderInfos = struct {
    const Self = @This();

    length: u32,
    type: [4]u8,

    pub fn loadFromStream(stream: *std.io.StreamSource) !Self {
        const reader = stream.reader();

        const length = try reader.readInt(u32, .big);
        var type_: [4]u8 = undefined;

        try reader.readNoEof(&type_);

        std.debug.print("Type: {s}\n", .{type_});
        std.debug.print("Len: {}\n", .{length});

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

    pub fn loadFromStream(stream: *std.io.StreamSource) !Self {
        const reader = stream.reader();

        const header_infos = try HeaderInfos.loadFromStream(stream);

        if (!std.mem.eql(u8, &header_infos.type, "IHDR")) {
            return Error.InvalidImageHeader;
        }

        if (header_infos.length != image_header_length) {
            return Error.InvalidImageHeader;
        }

        var data: [image_header_length]u8 = undefined;
        _ = try reader.readNoEof(&data);

        var data_stream = std.io.fixedBufferStream(&data);
        var data_reader = data_stream.reader();

        // Size
        const width = try data_reader.readInt(u32, .big);
        const height = try data_reader.readInt(u32, .big);

        // Bit depth
        const bit_depth = try data_reader.readInt(u8, .big);

        // Color type
        const color_type_byte = try data_reader.readInt(u8, .big);

        if (!std.mem.containsAtLeast(u8, &.{ 0, 2, 3, 4, 6 }, 1, &.{color_type_byte})) {
            return Error.InvalidImageHeader;
        }

        const color_type: ColorType = @enumFromInt(color_type_byte);

        if (color_type == .grayscale and
            !std.mem.containsAtLeast(u8, &.{ 1, 2, 4, 8, 16 }, 1, &.{bit_depth}))
        {
            return Error.InvalidImageHeader;
        }

        if ((color_type == .rgb_color or
            color_type == .grayscale_alpha or
            color_type == .rgba_color) and
            !std.mem.containsAtLeast(u8, &.{ 8, 16 }, 1, &.{bit_depth}))
        {
            return Error.InvalidImageHeader;
        }

        if (color_type == .palette_index and
            !std.mem.containsAtLeast(u8, &.{ 1, 2, 4, 8 }, 1, &.{bit_depth}))
        {
            return Error.InvalidImageHeader;
        }

        // Compression method
        const compression_method_byte = try data_reader.readInt(u8, .big);

        if (compression_method_byte != 0) {
            return Error.InvalidImageHeader;
        }

        const compression_method: CompressionMethod = @enumFromInt(compression_method_byte);

        // Filter method
        const filter_method_byte = try data_reader.readInt(u8, .big);

        if (filter_method_byte != 0) {
            return Error.InvalidImageHeader;
        }

        const filter_method: FilterMethod = @enumFromInt(filter_method_byte);

        // Interlace method
        const interlace_method_byte = try data_reader.readInt(u8, .big);

        if (interlace_method_byte != 0 and interlace_method_byte != 1) {
            return Error.InvalidImageHeader;
        }

        const interlace_method: InterlaceMethod = @enumFromInt(interlace_method_byte);

        // CRC
        try checkCrc(stream, header_infos, &data);

        return .{
            .width = width,
            .height = height,
            .bit_depth = bit_depth,
            .color_type = color_type,
            .compression_method = compression_method,
            .filter_method = filter_method,
            .interlace_method = interlace_method,
        };
    }

    pub inline fn allowsPalette(self: Self) bool {
        return self.color_type == .palette_index or
            self.color_type == .rgb or
            self.color_type == .rgba;
    }

    pub inline fn maxPaletteLength(self: Self) u32 {
        return std.math.pow(u32, 2, self.bit_depth);
    }

    pub inline fn channelCount(self: Self) u8 {
        return switch (self.color_type) {
            .grayscale => 1,
            .grayscale_alpha => 2,
            .palette_index => 1,
            .rgb => 3,
            .rgba => 4,
        };
    }

    pub inline fn pixelBits(self: Self) u8 {
        return self.bit_depth * self.channelCount();
    }

    pub inline fn lineBytes(self: Self) u32 {
        return (self.pixelBits() * self.width + 7) / 8;
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
    var file_signature: [signature.len]u8 = undefined;

    const reader = stream.reader();

    try reader.readNoEof(&file_signature);

    if (!std.mem.eql(u8, &file_signature, signature)) {
        return Error.InvalidSignature;
    }
}

fn checkCrc(stream: *std.io.StreamSource, header_infos: HeaderInfos, data: []const u8) !void {
    const reader = stream.reader();

    const expected = try reader.readInt(u32, .big);

    var crc = std.hash.Crc32.init();
    crc.update(&header_infos.type);
    crc.update(data);

    if (crc.final() != expected) {
        return error.InvalidCrc;
    }
}

fn loadPalette(
    allocator: std.mem.Allocator,
    stream: *std.io.StreamSource,
    image_infos: ImageInfos,
    header_infos: HeaderInfos,
    maybe_palette: *?std.ArrayList(root.Rgb24),
) !void {
    if (maybe_palette.* != null or
        !image_infos.allowsPalette() or
        header_infos.length % 3 != 0)
    {
        return Error.InvalidPalette;
    }

    const length = header_infos.length / 3;

    if (length > image_infos.maxPaletteLength()) {
        return Error.InvalidPalette;
    }

    var palette = try std.ArrayList(root.Rgb24).initCapacity(allocator, length);
    errdefer palette.deinit();

    palette.expandToCapacity();

    var data = std.ArrayList(u8).init(allocator);
    defer data.deinit();

    const reader = stream.reader();

    for (0..length) |i| {
        var buffer: [3]u8 = undefined;
        try reader.readNoEof(&buffer);

        palette.items[i].red = buffer[0];
        palette.items[i].green = buffer[1];
        palette.items[i].blue = buffer[2];

        try data.appendSlice(&buffer);
    }

    maybe_palette.* = palette;

    try checkCrc(stream, header_infos, data.items);
}

fn loadData(
    stream: *std.io.StreamSource,
    image_infos: ImageInfos,
    maybe_palette: ?[]const root.Rgb24,
) !void {
    if (maybe_palette.* == null and image_infos.color_type == .palette_index) {
        return Error.InvalidData;
    }

    if (maybe_palette.* != null and
        !std.mem.containsAtLeast(
        ColorType,
        &.{ .palette_index, .rgb_color, .rgba_color },
        1,
        &.{image_infos.color_type},
    )) {
        return Error.InvalidData;
    }

    const reader = stream.reader();

    const decompressor = std.compress.zlib.decompressor(reader);
    const decompressor_reader = decompressor.reader();

    switch (image_infos.interlace_method) {
        .none => {},
        .adam7 => {},
    }
}

fn loadAncillaryChunk(stream: std.io.StreamSource, header_infos: HeaderInfos) !void {
    const reader = stream.reader();

    reader.skipBytes(header_infos.length, .{}) catch {
        return Error.InvalidData;
    };
}

fn loadChunk(
    allocator: std.mem.Allocator,
    stream: *std.io.StreamSource,
    image_infos: ImageInfos,
    header_infos: HeaderInfos,
    maybe_palette: *?std.ArrayList(root.Rgb24),
) !void {
    if (std.mem.eql(u8, &header_infos.type, "PLTE")) {
        try loadPalette(allocator, stream, image_infos, header_infos, maybe_palette);
    } else if (std.mem.eql(u8, &header_infos.type, "IDAT")) {
        const palette = if (maybe_palette) |palette|
            palette.items
        else
            null;

        try loadData(allocator, image_infos, stream, palette);
    } else {
        try loadAncillaryChunk(stream, header_infos);
    }
}

pub fn loadFromFile(allocator: std.mem.Allocator, file: std.fs.File) !root.Image {
    var stream = std.io.StreamSource{ .file = file };
    return try loadFromStream(allocator, &stream);
}

pub fn loadFromStream(allocator: std.mem.Allocator, stream: *std.io.StreamSource) !root.Image {
    try checkSignature(stream);

    const image_infos = try ImageInfos.loadFromStream(stream);

    var image = root.Image.init(allocator);
    errdefer image.deinit();

    image.size = .{ image_infos.width, image_infos.height };

    var maybe_palette: ?std.ArrayList(root.Rgb24) = null;

    errdefer {
        if (maybe_palette) |palette| {
            palette.deinit();
        }
    }

    while (true) {
        const header_infos = try HeaderInfos.loadFromStream(stream);

        if (std.mem.eql(u8, &header_infos.type, "IEND")) {
            break;
        }

        try loadChunk(
            allocator,
            stream,
            image_infos,
            header_infos,
            &maybe_palette,
        );
    }

    return image;
}
