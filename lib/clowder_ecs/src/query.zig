const Registry = @import("Registry.zig");
const Entity = Registry.Entity;

pub fn Query(comptime includes: anytype, comptime excludes: anytype) type {
    {
        const IncludesType = @TypeOf(includes);

        if (@typeInfo(IncludesType) != .Struct) {
            @compileError("Expected tuple for includes, found '" ++ @typeName(IncludesType) ++ "'");
        }
    }

    {
        const ExcludesType = @TypeOf(excludes);

        if (@typeInfo(ExcludesType) != .Struct) {
            @compileError("Expected tuple for excludes, found '" ++ @typeName(ExcludesType) ++ "'");
        }
    }

    for (includes) |include| {
        const Include = @TypeOf(include);

        if (@typeInfo(Include) != .Type) {
            @compileError("Expected type, found '" ++ @typeName(Include) ++ "'");
        }
    }

    for (excludes) |exclude| {
        const Exclude = @TypeOf(exclude);

        if (@typeInfo(Exclude) != .Type) {
            @compileError("Excpeted type, found '" ++ @typeName(Exclude) ++ "'");
        }
    }

    for (includes) |include| {
        for (excludes) |exclude| {
            if (include == exclude) {
                @compileError("'" ++ @typeName(include) ++ "' found both in includes and exculdes");
            }
        }
    }

    return struct {
        const Self = @This();

        pub fn init(registry: Registry) Self {
            _ = registry;
            return .{};
        }

        pub fn next(self: *Self) Entity {
            _ = self;
        }
    };
}
