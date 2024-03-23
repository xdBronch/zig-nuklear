const c = @import("c.zig");
const nk = @import("../nuklear.zig");
const std = @import("std");

const builtin = std.builtin;
const debug = std.debug;
const heap = std.heap;
const math = std.math;
const mem = std.mem;
const meta = std.meta;
const testing = std.testing;

pub fn begin(ctx: *nk.Context, name: []const u8, flags: nk.PanelFlags) bool {
    return c.nk_group_begin_titled(
        ctx,
        nk.slice(name),
        nk.slice(flags.title orelse ""),
        flags.toNuklear(),
    ) != 0;
}

pub fn end(ctx: *nk.Context) void {
    c.nk_group_end(ctx);
}

pub fn scrolledOffsetBegin(
    ctx: *nk.Context,
    offset: *nk.ScrollOffset,
    comptime Id: type,
    flags: nk.PanelFlags,
) bool {
    const id = nk.typeId(Id);
    var c_x_offset: c.nk_uint = @as(c.nk_uint, @intCast(offset.x));
    var c_y_offset: c.nk_uint = @as(c.nk_uint, @intCast(offset.y));
    defer {
        offset.x = @as(usize, @intCast(c_x_offset));
        offset.y = @as(usize, @intCast(c_y_offset));
    }
    return c.nk_group_scrolled_offset_begin(
        ctx,
        &c_x_offset,
        &c_y_offset,
        nk.slice(flags.title orelse mem.asBytes(&id)),
        flags.toNuklear(),
    ) != 0;
}

pub fn scrolledBegin(
    ctx: *nk.Context,
    off: *nk.Scroll,
    comptime Id: type,
    flags: nk.PanelFlags,
) bool {
    const id = nk.typeId(Id);
    return c.nk_group_scrolled_begin(
        ctx,
        off,
        nk.slice(flags.title orelse mem.asBytes(&id)),
        flags.toNuklear(),
    ) != 0;
}

pub fn scrolledEnd(ctx: *nk.Context) void {
    c.nk_group_scrolled_end(ctx);
}

pub fn getScroll(ctx: *nk.Context, comptime Id: type) nk.ScrollOffset {
    const id = nk.typeId(Id);
    return getScrollByName(ctx, mem.asBytes(&id));
}

pub fn getScrollByName(ctx: *nk.Context, name: []const u8) nk.ScrollOffset {
    var x_offset: c.nk_uint = undefined;
    var y_offset: c.nk_uint = undefined;
    c.nk_group_get_scroll(ctx, nk.slice(name), &x_offset, &y_offset);
    return .{
        .x = x_offset,
        .y = y_offset,
    };
}

pub fn setScroll(ctx: *nk.Context, comptime Id: type, offset: nk.ScrollOffset) void {
    const id = nk.typeId(Id);
    return setScrollByName(ctx, mem.asBytes(&id), offset);
}

pub fn setScrollByName(
    ctx: *nk.Context,
    name: []const u8,
    offset: nk.ScrollOffset,
) void {
    c.nk_group_set_scroll(
        ctx,
        nk.slice(name),
        @as(c.nk_uint, @intCast(offset.x)),
        @as(c.nk_uint, @intCast(offset.y)),
    );
}

test {
    testing.refAllDecls(@This());
}

test "group" {
    const ctx = &try nk.testing.init();
    defer nk.free(ctx);

    if (nk.window.begin(ctx, &nk.id(opaque {}), nk.rect(10, 10, 10, 10), .{})) |_| {
        nk.layout.rowDynamic(ctx, 10, 1);
        if (nk.group.begin(ctx, &nk.id(opaque {}), .{})) {
            defer nk.group.end(ctx);
        }
    }
    nk.window.end(ctx);
}
