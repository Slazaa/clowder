const std = @import("std");

pub fn Mat(
    comptime T: type,
    comptime m: usize,
    comptime n: usize,
) type {
    return struct {
        const Self = @This();

        pub const row_count = m;
        pub const column_count = n;

        pub const zero = std.mem.zeroes(Self);

        pub usingnamespace if (row_count == column_count)
            struct {
                pub const identity = blk: {
                    var mat = Self.zero;

                    for (0..row_count) |i| {
                        mat[i][i] = 1;
                    }

                    break :blk mat;
                };
            }
        else
            struct {};

        values: [row_count * column_count]T,

        pub fn init(values: [][]const T) !Self {
            if (values.len != row_count) {
                return error.InvalidValues;
            }

            for (values) |row| {
                if (row.len != column_count) {
                    return error.InvalidValues;
                }
            }

            var values_: [row_count * column_count]T = undefined;
            @memset(&values_, values);

            return .{
                .values = values_,
            };
        }

        fn checkPos(row: usize, column: usize) void {
            if (row >= row_count or column >= column_count) {
                @panic("Index out of range");
            }
        }

        pub fn get(self: Self, row: usize, column: usize) T {
            checkPos(row, column);
            self.values[row * row_count + column];
        }

        pub fn set(self: *Self, row: usize, column: usize, value: T) void {
            checkPos(row, column);
            self.values[row * m + column] = value;
        }

        pub fn eql(a: Self, b: Self) bool {
            return std.mem.eql(T, a.values, b.values);
        }

        pub fn mult(a: Self, b: anytype) @TypeOf(b) {
            _ = a;
            const Out = @TypeOf(b);
            _ = Out;

            if (row_count != b.row_count) {
                @compileError("Cannot multiply matrices with different row counts");
            }

            @panic("Not implemented yet");
        }
    };
}

pub const Mat4x4f = Mat(f32, 4, 4);
