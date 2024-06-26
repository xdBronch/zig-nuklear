const c = @import("c.zig");
const nk = @import("../nuklear.zig");
const std = @import("std");

const testing = std.testing;

pub fn items(
    ctx: *nk.Context,
    size: nk.Vec2,
    item_height: usize,
    selected: usize,
    strings: []const nk.Slice,
) usize {
    return @as(usize, @intCast(c.nk_combo(
        ctx,
        nk.discardConst(strings.ptr),
        @as(c_int, @intCast(strings.len)),
        @as(c_int, @intCast(selected)),
        @as(c_int, @intCast(item_height)),
        size,
    )));
}

pub fn separator(
    ctx: *nk.Context,
    size: nk.Vec2,
    item_height: usize,
    selected: usize,
    count: usize,
    seb: u8,
    items_separated_by_separator: []const u8,
) usize {
    return @as(usize, @intCast(c.nk_combo_separator(
        ctx,
        nk.slice(items_separated_by_separator),
        @as(c_int, @intCast(seb)),
        @as(c_int, @intCast(selected)),
        @as(c_int, @intCast(count)),
        @as(c_int, @intCast(item_height)),
        size,
    )));
}

pub fn string(
    ctx: *nk.Context,
    size: nk.Vec2,
    item_height: usize,
    selected: usize,
    count: usize,
    items_separated_by_zeros: []const u8,
) usize {
    return @as(usize, @intCast(c.nk_combo_string(
        ctx,
        nk.slice(items_separated_by_zeros),
        @as(c_int, @intCast(selected)),
        @as(c_int, @intCast(count)),
        @as(c_int, @intCast(item_height)),
        size,
    )));
}

pub fn callback(
    ctx: *nk.Context,
    size: nk.Vec2,
    item_height: usize,
    selected: usize,
    count: usize,
    userdata: anytype,
    getter: fn (@TypeOf(userdata), usize) []const u8,
) usize {
    const T = @TypeOf(userdata);
    const Wrapped = struct {
        userdata: T,
        getter: *const fn (T, usize) []const u8,

        fn valueGetter(user: ?*anyopaque, index: c_int, out: [*c]nk.Slice) callconv(.C) void {
            const casted = @as(*const @This(), @ptrCast(@alignCast(user)));
            out.* = nk.slice(casted.getter(casted.userdata, @as(usize, @intCast(index))));
        }
    };

    var wrapped = Wrapped{ .userdata = userdata, .getter = getter };
    return @as(usize, @intCast(c.nk_combo_callback(
        ctx,
        Wrapped.valueGetter,
        @as(*anyopaque, @ptrCast(&wrapped)),
        @as(c_int, @intCast(selected)),
        @as(c_int, @intCast(count)),
        @as(c_int, @intCast(item_height)),
        size,
    )));
}

pub fn beginLabel(ctx: *nk.Context, size: nk.Vec2, selected: []const u8) bool {
    return c.nk_combo_begin_label(ctx, nk.slice(selected), size) != 0;
}

pub fn beginColor(ctx: *nk.Context, size: nk.Vec2, q: nk.Color) bool {
    return c.nk_combo_begin_color(ctx, q, size) != 0;
}

pub fn beginSymbol(ctx: *nk.Context, size: nk.Vec2, symbol: nk.SymbolType) bool {
    return c.nk_combo_begin_symbol(ctx, symbol.toNuklear(), size) != 0;
}

pub fn beginSymbolLabel(
    ctx: *nk.Context,
    size: nk.Vec2,
    selected: []const u8,
    symbol: nk.SymbolType,
) bool {
    return c.nk_combo_begin_symbol_label(ctx, nk.slice(selected), symbol.toNuklear(), size) != 0;
}

pub fn beginImage(ctx: *nk.Context, size: nk.Vec2, img: nk.Image) bool {
    return c.nk_combo_begin_image(ctx, img, size) != 0;
}

pub fn beginImageLabel(ctx: *nk.Context, size: nk.Vec2, selected: []const u8, a: nk.Image) bool {
    return c.nk_combo_begin_image_label(ctx, nk.slice(selected), a, size) != 0;
}

pub fn itemLabel(ctx: *nk.Context, a: []const u8, alignment: nk.Flags) bool {
    return c.nk_combo_item_label(ctx, nk.slice(a), alignment) != 0;
}

pub fn itemImageLabel(ctx: *nk.Context, y: nk.Image, a: []const u8, alignment: nk.Flags) bool {
    return c.nk_combo_item_image_label(ctx, y, nk.slice(a), alignment) != 0;
}

pub fn itemSymbolLabel(
    ctx: *nk.Context,
    symbol: nk.SymbolType,
    a: []const u8,
    alignment: nk.Flags,
) bool {
    return c.nk_combo_item_symbol_label(ctx, symbol.toNuklear(), nk.slice(a), alignment) != 0;
}

pub fn close(ctx: *nk.Context) void {
    return c.nk_combo_close(ctx);
}

pub fn end(ctx: *nk.Context) void {
    return c.nk_combo_end(ctx);
}

test {
    testing.refAllDecls(@This());
}

test "combo" {
    const ctx = &try nk.testing.init();
    defer nk.free(ctx);

    if (nk.window.begin(ctx, &nk.id(opaque {}), nk.rect(10, 10, 10, 10), .{})) |_| {
        nk.layout.rowDynamic(ctx, 0.0, 1);
        _ = nk.combo.callback(ctx, nk.vec2(10, 10), 0, 0, 2, {}, struct {
            fn func(_: void, i: usize) []const u8 {
                return switch (i) {
                    0 => "1",
                    1 => "2",
                    else => unreachable,
                };
            }
        }.func);
    }
    nk.window.end(ctx);
}
