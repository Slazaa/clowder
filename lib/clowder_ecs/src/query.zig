const std = @import("std");

const Registry = @import("Registry.zig");
const Entity = Registry.Entity;

const Storage = @import("storage.zig").Storage;

pub fn Query(comptime includes: anytype, comptime excludes: anytype) type {
    {
        const IncludesType = @TypeOf(includes);

        if (@typeInfo(IncludesType) != .Struct) {
            @compileError("Expected tuple for includes, found '" ++ @typeName(IncludesType) ++ "'");
        }

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

        registry: Registry,

        include_entity_lists: [includes.len - 1][]const Entity,
        include_base_entity_list: []const Entity,

        exclude_entity_lists: [includes.len - 1][]const Entity,
        exclude_base_entity_list: []const Entity,

        index: usize = 0,

        pub fn init(registry: Registry) Self {
            var include_entity_lists: [includes.len - 1][]const Entity = undefined;
            var include_base_entity_list: []const Entity = undefined;

            inline for (includes, 0..) |Include, i| {
                const entity_list: []const Entity = if (registry.getStorage(Include)) |storage|
                    storage.entities.items
                else |_|
                    &.{};

                if (i == 0) {
                    include_base_entity_list = entity_list;
                } else if (entity_list.len < include_base_entity_list.len) {
                    include_entity_lists[i] = include_base_entity_list;
                    include_base_entity_list = entity_list;
                } else {
                    include_entity_lists[i] = entity_list;
                }
            }

            var exclude_entity_lists: [includes.len - 1][]const Entity = undefined;
            var exclude_base_entity_list: []const Entity = undefined;

            inline for (excludes, 1..) |Exclude, i| {
                const entity_list: []const Entity = if (registry.getStorage(Exclude)) |storage|
                    storage.entities.items
                else |_|
                    &.{};

                if (entity_list.len < exclude_base_entity_list.len) {
                    exclude_entity_lists[i] = exclude_base_entity_list;
                    exclude_base_entity_list = entity_list;
                } else {
                    exclude_entity_lists[i] = entity_list;
                }
            }

            return .{
                .registry = registry,

                .include_entity_lists = include_entity_lists,
                .include_base_entity_list = include_base_entity_list,

                .exclude_entity_lists = exclude_entity_lists,
                .exclude_base_entity_list = exclude_base_entity_list,
            };
        }

        /// Returns the next `Entity` in the `Query`.
        pub fn next(self: *Self) ?Entity {
            if (self.include_base_entity_list.len == 0 or
                self.index >= self.include_base_entity_list.len)
            {
                return null;
            }

            const entity = self.include_base_entity_list[self.index];

            const incl_valid = for (self.include_entity_lists) |incl_entity| {
                if (incl_entity != entity) break false;
            } else true;

            self.index += 1;

            if (incl_valid) {
                return entity;
            }

            return self.next();
        }
    };
}
