const std = @import("std");

const math = @import("clowder_math");

const root = @import("root.zig");

const signature = "\x89PNG\x0D\x0A\x1A\x0A";
const max_length = std.math.pow(2, 31);

const image_header_length = 13;
const image_end_length = 0;

const HeaderInfos = struct {
    length: u32,
    type: [4]u8,
};

const Chunk = struct {
    data: std.ArrayList(u8),
};

const ColorType = enum(u8) {
    grayscale = 0,
    rgb_color = 2,
    indexed = 3,
    grayscale_alpha = 4,
    rgba_color = 6,
};

fn checkSignature(reader: std.fs.File.Reader) root.Error!void {
    var file_signature: [signature.len]u8 = undefined;

    try reader.readNoEof(&file_signature);

    if (!std.mem.eql(u8, &file_signature, signature)) {
        return root.Error.InvalidData;
    }
}

fn checkCrc(reader: std.fs.File.Reader, chunk: Chunk) !void {
    _ = chunk;
    _ = reader;
}

fn loadHeaderInfos(reader: std.fs.File.Reader) !HeaderInfos {
    var header_infos: HeaderInfos = undefined;
    header_infos.length = try reader.readInt(u32, .big);

    try reader.readNoEof(&header_infos.type);
}

fn loadCriticalChunk(
    allocator: std.mem.Allocator,
    reader: std.fs.File.Reader,
    image: *root.Image,
    color_type: *ColorType,
    palette: *?std.ArrayList(root.Rgb24),
    header_infos: HeaderInfos,
) !?Chunk {
    var chunk: Chunk = undefined;

    // Image header.
    if (std.mem.eql(u8, &header_infos.type, "IHDR")) {
        if (header_infos.length != image_header_length) {
            return root.Error.InvalidData;
        }

        image.size[0] = try reader.readInt(u32, .big);
        image.size[1] = try reader.readInt(u32, .big);

        try reader.skipBytes(1, .{});

        color_type.* = @enumFromInt(try reader.readInt(u8, .big));
    }

    // Image data.
    else if (std.mem.eql(u8, &header_infos.type, "IDAT")) {
        //
    }

    // Palette.
    else if (std.mem.eql(u8, &header_infos.type, "PLTE")) {
        if (color_type.* != .indexed and
            color_type.* != .rgb_color and
            color_type.* != .rgba_color)
        {
            return root.Error.InvalidData;
        }

        if (header_infos.length % 3 != 0) {
            return root.Error.InvalidData;
        }

        const entry_count = header_infos.length / 3;

        if (palette != null) {
            return root.Error.InvalidData;
        }

        palette = std.ArrayList(root.Rgb24).initCapacity(allocator, entry_count);
        palette.?.expandToCapacity();

        try reader.readNoEof(palette.?.items);
    }

    // Image end.
    else if (std.mem.eql(u8, &header_infos.type, "IEND")) {
        if (header_infos.length != image_end_length) {
            return root.Error.InvalidData;
        }

        return null;
    }

    // Is not critical.
    else {
        return error.InvalidChunk;
    }

    return chunk;
}

fn loadAncillaryChunk(reader: std.fs.File.Reader, image: *root.Image, header_infos: HeaderInfos) !?Chunk {
    _ = image;

    // Ignore.
    reader.skipBytes(header_infos.length, .{}) catch {
        return root.Error.InvalidData;
    };

    return true;
}

fn loadChunk(
    allocator: std.mem.Allocator,
    reader: std.fs.File.Reader,
    image: *root.Image,
    color_type: *ColorType,
    header_infos: HeaderInfos,
) !?Chunk {
    if (loadCriticalChunk(
        allocator,
        reader,
        image,
        color_type,
        header_infos,
    )) |chunk| {
        return chunk;
    } else |err| {
        if (err != error.InvalidData) {
            return err;
        }
    }

    if (loadAncillaryChunk(reader, image, header_infos)) |chunk| {
        return chunk;
    } else |err| {
        if (err != error.InvalidData) {
            return err;
        }
    }

    return null;
}

pub fn load(allocator: std.mem.Allocator, reader: std.fs.File.Reader) !root.Image {
    var image = root.Image.init(allocator);
    errdefer image.deinit();

    try checkSignature(reader);

    var color_type: ColorType = undefined;

    while (true) {
        const header_infos = try loadHeaderInfos(reader);

        const chunk = try loadChunk(
            allocator,
            reader,
            &image,
            &color_type,
            header_infos,
        ) orelse {
            break;
        };

        try checkCrc(reader, chunk);
    }

    return image;
}
