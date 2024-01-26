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

fn checkSignature(reader: std.fs.File.Reader) root.Error!void {
    var file_signature: [8]u8 = undefined;

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

fn loadCriticalChunk(reader: std.fs.File.Reader, image: *root.Image, header_infos: HeaderInfos) !?Chunk {
    var chunk: Chunk = undefined;

    // Image header.
    if (std.mem.eql(u8, &header_infos.type, "IHDR")) {
        if (header_infos.length != image_header_length) {
            return root.Error.InvalidData;
        }

        image.size[0] = try reader.readInt(u32, .big);
        image.size[1] = try reader.readInt(u32, .big);
    }

    // Image data.
    else if (std.mem.eql(u8, &header_infos.type, "IDAT")) {
        //
    }

    // Palette.
    else if (std.mem.eql(u8, &header_infos.type, "PLTE")) {
        //
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

fn loadChunk(reader: std.fs.File.Reader, image: *root.Image, header_infos: HeaderInfos) !?Chunk {
    if (loadCriticalChunk(reader, image, header_infos)) |chunk| {
        return chunk;
    } else |err| {
        switch (err) {
            error.InvalidData => {},
            else => return err,
        }
    }

    if (loadAncillaryChunk(reader, image, header_infos)) |chunk| {
        return chunk;
    } else |err| {
        switch (err) {
            error.InvalidData => {},
            else => return err,
        }
    }

    return null;
}

pub fn load(allocator: std.mem.Allocator, reader: std.fs.File.Reader) !root.Image {
    var image = root.Image.init(allocator);
    errdefer image.deinit();

    try checkSignature(reader);

    while (true) {
        const header_infos = try loadHeaderInfos(reader);

        const chunk = try loadChunk(reader, &image, header_infos) orelse {
            break;
        };

        try checkCrc(reader, chunk);
    }

    return image;
}
