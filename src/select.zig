const c = @import("c.zig");
const nk = @import("../nuklear.zig");
const std = @import("std");

const mem = std.mem;
const testing = std.testing;

pub fn label(ctx: *nk.Context, title: []const u8, flags: nk.Flags, value: bool) bool {
    return c.nk_select_label(ctx, nk.slice(title), flags, @intFromBool(value)) != 0;
}

pub fn imageLabel(
    ctx: *nk.Context,
    img: nk.Image,
    title: []const u8,
    flags: nk.Flags,
    value: bool,
) bool {
    return c.nk_select_image_label(ctx, img, nk.slice(title), flags, @intFromBool(value)) != 0;
}

pub fn symbolLabel(
    ctx: *nk.Context,
    symbol: nk.SymbolType,
    title: []const u8,
    flags: nk.Flags,
    value: bool,
) bool {
    return c.nk_select_symbol_label(
        ctx,
        symbol.toNuklear(),
        nk.slice(title),
        flags,
        @intFromBool(value),
    ) != 0;
}

test {
    testing.refAllDecls(@This());
}
