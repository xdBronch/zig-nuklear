const c = @import("c.zig");
const std = @import("std");

const builtin = std.builtin;
const debug = std.debug;
const math = std.math;
const mem = std.mem;
const meta = std.meta;

const nk = @This();

pub const atlas = @import("atlas.zig");
pub const bar = @import("bar.zig");
pub const button = @import("button.zig");
pub const check = @import("check.zig");
pub const checkbox = @import("checkbox.zig");
pub const color = @import("color.zig");
pub const group = @import("group.zig");
pub const input = @import("input.zig");
pub const layout = @import("layout.zig");
pub const list = @import("list.zig");
pub const option = @import("option.zig");
pub const radio = @import("radio.zig");
pub const select = @import("select.zig");
pub const selectable = @import("selectable.zig");
pub const slide = @import("slide.zig");
pub const slider = @import("slider.zig");
pub const testing = @import("testing.zig");
pub const text = @import("text.zig");
pub const tree = @import("tree.zig");
pub const widget = @import("widget.zig");
pub const window = @import("window.zig");

pub const property = struct {
    pub fn int(ctx: *nk.Context, name: []const u8, min: c_int, val: *c_int, max: c_int, step: c_int, inc_per_pixel: f32) void {
        return c.nk_property_int(ctx, nk.slice(name), min, val, max, step, inc_per_pixel);
    }

    pub fn float(ctx: *nk.Context, name: []const u8, min: f32, val: *f32, max: f32, step: f32, inc_per_pixel: f32) void {
        return c.nk_property_float(ctx, nk.slice(name), min, val, max, step, inc_per_pixel);
    }

    pub fn double(ctx: *nk.Context, name: []const u8, min: f64, val: *f64, max: f64, step: f64, inc_per_pixel: f32) void {
        return c.nk_property_double(ctx, nk.slice(name), min, val, max, step, inc_per_pixel);
    }

    pub fn i(ctx: *nk.Context, name: []const u8, min: c_int, val: c_int, max: c_int, step: c_int, inc_per_pixel: f32) c_int {
        return c.nk_propertyi(ctx, nk.slice(name), min, val, max, step, inc_per_pixel);
    }

    pub fn f(ctx: *nk.Context, name: []const u8, min: f32, val: f32, max: f32, step: f32, inc_per_pixel: f32) f32 {
        return c.nk_propertyf(ctx, nk.slice(name), min, val, max, step, inc_per_pixel);
    }

    pub fn d(ctx: *nk.Context, name: []const u8, min: f64, val: f64, max: f64, step: f64, inc_per_pixel: f32) f64 {
        return c.nk_propertyd(ctx, nk.slice(name), min, val, max, step, inc_per_pixel);
    }

    test {
        std.testing.refAllDecls(@This());
    }
};

pub const edit = struct {
    pub const Text = c.nk_text_edit;

    pub fn string(ctx: *nk.Context, flags: nk.Flags, buf: *[]u8, max: usize, filter: nk.Filter) nk.Flags {
        var c_len = @intCast(c_int, buf.len);
        defer buf.len = @intCast(usize, c_len);
        return c.nk_edit_string(ctx, flags, buf.ptr, &c_len, @intCast(c_int, max), filter);
    }

    pub fn stringZ(ctx: *nk.Context, flags: nk.Flags, buf: [*:0]u8, max: usize, filter: nk.Filter) nk.Flags {
        return c.nk_edit_string_zero_terminated(ctx, flags, buf, @intCast(c_int, max), filter);
    }

    pub fn buffer(ctx: *nk.Context, flags: nk.Flags, t: *Text, filter: nk.Filter) nk.Flags {
        return c.nk_edit_buffer(ctx, flags, t, filter);
    }

    pub fn focus(ctx: *nk.Context, flags: nk.Flags) void {
        return c.nk_edit_focus(ctx, flags);
    }

    pub fn unfocus(ctx: *nk.Context) void {
        return c.nk_edit_unfocus(ctx);
    }

    test {
        std.testing.refAllDecls(@This());
    }
};

pub const chart = struct {
    pub fn begin(ctx: *nk.Context, a: nk.ChartType, num: usize, min: f32, max: f32) bool {
        return c.nk_chart_begin(ctx, a, @intCast(c_int, num), min, max) != 0;
    }

    pub fn beginColored(ctx: *nk.Context, y: nk.ChartType, a: nk.Color, active: nk.Color, num: usize, min: f32, max: f32) bool {
        return c.nk_chart_begin_colored(ctx, y, a, active, @intCast(c_int, num), min, max) != 0;
    }

    pub fn addSlot(ctx: *nk.Context, a: nk.ChartType, count: usize, min_value: f32, max_value: f32) void {
        return c.nk_chart_add_slot(ctx, a, @intCast(c_int, count), min_value, max_value);
    }

    pub fn addSlotColored(ctx: *nk.Context, y: nk.ChartType, a: nk.Color, active: nk.Color, count: usize, min_value: f32, max_value: f32) void {
        return c.nk_chart_add_slot_colored(ctx, y, a, active, @intCast(c_int, count), min_value, max_value);
    }

    pub fn push(ctx: *nk.Context, value: f32) nk.Flags {
        return c.nk_chart_push(ctx, value);
    }

    pub fn pushSlot(ctx: *nk.Context, value: f32, slot: usize) nk.Flags {
        return c.nk_chart_push_slot(ctx, value, @intCast(c_int, slot));
    }

    pub fn end(ctx: *nk.Context) void {
        return c.nk_chart_end(ctx);
    }

    pub fn plot(ctx: *nk.Context, a: nk.ChartType, values: []const f32, offset: c_int) void {
        return c.nk_plot(ctx, a, values.ptr, @intCast(c_int, values.len), offset);
    }

    pub fn plotFunction(ctx: *nk.Context, y: nk.ChartType, userdata: anytype, getter: fn (@TypeOf(userdata), usize) f32, count: usize, offset: usize) void {
        const T = @TypeOf(userdata);
        const Wrapped = struct {
            userdata: T,
            getter: fn (T, usize) f32,

            fn valueGetter(user: ?*c_void, index: c_int) callconv(.C) f32 {
                const casted = @ptrCast(*const @This(), @alignCast(@alignOf(@This()), user));
                return casted.getter(casted.userdata, @intCast(usize, index));
            }
        };

        var wrapped = Wrapped{ .userdata = userdata, .getter = getter };
        return c.nk_plot_function(
            ctx,
            y,
            @ptrCast(*c_void, &wrapped),
            Wrapped.valueGetter,
            @intCast(c_int, count),
            @intCast(c_int, offset),
        );
    }

    test {
        std.testing.refAllDecls(@This());
    }

    test "chart" {
        var ctx = &try nk.testing.init();
        defer nk.free(ctx);

        if (nk.window.begin(ctx, opaque {}, "test", nk.rect(10, 10, 10, 10), 0)) |win| {
            nk.layout.rowDynamic(ctx, 0.0, 1);
            nk.chart.plotFunction(ctx, .NK_CHART_LINES, {}, struct {
                fn func(_: void, i: usize) f32 {
                    return @intToFloat(f32, i);
                }
            }.func, 10, 0);
        }
        nk.window.end(ctx);
    }
};

pub const popup = struct {
    pub fn begin(ctx: *nk.Context, d: nk.PopupType, y: []const u8, a: nk.Flags, bounds: nk.Rect) bool {
        return c.nk_popup_begin(ctx, d, nk.slice(y), a, bounds) != 0;
    }

    pub fn close(ctx: *nk.Context) void {
        return c.nk_popup_close(ctx);
    }

    pub fn end(ctx: *nk.Context) void {
        return c.nk_popup_end(ctx);
    }

    pub fn getScroll(ctx: *nk.Context) nk.ScrollOffset {
        var x_offset: c.nk_uint = undefined;
        var y_offset: c.nk_uint = undefined;
        c.nk_popup_get_scroll(ctx, &x_offset, &y_offset);
        return .{
            .x = x_offset,
            .y = y_offset,
        };
    }

    pub fn setScroll(ctx: *nk.Context, offset: nk.ScrollOffset) void {
        c.nk_popup_set_scroll(
            ctx,
            @intCast(c.nk_uint, offset.x),
            @intCast(c.nk_uint, offset.y),
        );
    }

    test {
        std.testing.refAllDecls(@This());
    }
};

pub const combobox = struct {
    pub fn items(ctx: *nk.Context, strings: []const nk.Slice, selected: [*c]c_int, item_height: c_int, size: nk.Vec2) void {
        return c.nk_combobox(
            ctx,
            discardConst(strings.ptr),
            @intCast(c_int, strings.len),
            selected,
            item_height,
            size,
        );
    }

    pub fn string(ctx: *nk.Context, items_separated_by_zeros: []const u8, selected: [*c]c_int, count: c_int, item_height: c_int, size: nk.Vec2) void {
        return c.nk_combobox_string(ctx, nk.slice(items_separated_by_zeros), selected, count, item_height, size);
    }

    pub fn separator(ctx: *nk.Context, items_separated_by_separator: []const u8, seb: c_int, selected: [*c]c_int, count: c_int, item_height: c_int, size: nk.Vec2) void {
        return c.nk_combobox_separator(ctx, nk.slice(items_separated_by_separator), seb, selected, count, item_height, size);
    }

    pub fn callback(ctx: *nk.Context, item_getter: ?fn (?*c_void, c_int, [*c]nk.Slice) callconv(.C) void, a: ?*c_void, selected: [*c]c_int, count: c_int, item_height: c_int, size: nk.Vec2) void {
        return c.nk_combobox_callback(ctx, item_getter, a, selected, count, item_height, size);
    }

    test {
        std.testing.refAllDecls(@This());
    }
};

pub const combo = struct {
    pub fn items(ctx: *nk.Context, strings: []const nk.Slice, selected: c_int, item_height: c_int, size: nk.Vec2) c_int {
        return c.nk_combo(
            ctx,
            discardConst(strings.ptr),
            @intCast(c_int, strings.len),
            selected,
            item_height,
            size,
        );
    }

    pub fn separator(ctx: *nk.Context, items_separated_by_separator: []const u8, seb: c_int, selected: c_int, count: c_int, item_height: c_int, size: nk.Vec2) c_int {
        return c.nk_combo_separator(ctx, nk.slice(items_separated_by_separator), seb, selected, count, item_height, size);
    }

    pub fn string(ctx: *nk.Context, items_separated_by_zeros: []const u8, selected: c_int, count: c_int, item_height: c_int, size: nk.Vec2) c_int {
        return c.nk_combo_string(ctx, nk.slice(items_separated_by_zeros), selected, count, item_height, size);
    }

    pub fn callback(ctx: *nk.Context, item_getter: ?fn (?*c_void, c_int, [*c]nk.Slice) callconv(.C) void, userdata: ?*c_void, selected: c_int, count: c_int, item_height: c_int, size: nk.Vec2) c_int {
        return c.nk_combo_callback(ctx, item_getter, userdata, selected, count, item_height, size);
    }

    pub fn beginLabel(ctx: *nk.Context, selected: []const u8, size: nk.Vec2) bool {
        return c.nk_combo_begin_label(ctx, nk.slice(selected), size) != 0;
    }

    pub fn beginColor(ctx: *nk.Context, q: nk.Color, size: nk.Vec2) bool {
        return c.nk_combo_begin_color(ctx, q, size) != 0;
    }

    pub fn beginSymbol(ctx: *nk.Context, a: nk.SymbolType, size: nk.Vec2) bool {
        return c.nk_combo_begin_symbol(ctx, a, size) != 0;
    }

    pub fn beginSymbolLabel(ctx: *nk.Context, selected: []const u8, a: nk.SymbolType, size: nk.Vec2) bool {
        return c.nk_combo_begin_symbol_label(ctx, nk.slice(selected), a, size) != 0;
    }

    pub fn beginImage(ctx: *nk.Context, img: nk.Image, size: nk.Vec2) bool {
        return c.nk_combo_begin_image(ctx, img, size) != 0;
    }

    pub fn beginImageLabel(ctx: *nk.Context, selected: []const u8, a: nk.Image, size: nk.Vec2) bool {
        return c.nk_combo_begin_image_label(ctx, nk.slice(selected), a, size) != 0;
    }

    pub fn itemLabel(ctx: *nk.Context, a: []const u8, alignment: nk.Flags) bool {
        return c.nk_combo_item_label(ctx, nk.slice(a), alignment) != 0;
    }

    pub fn itemImageLabel(ctx: *nk.Context, y: nk.Image, a: []const u8, alignment: nk.Flags) bool {
        return c.nk_combo_item_image_label(ctx, y, nk.slice(a), alignment) != 0;
    }

    pub fn itemSymbolLabel(ctx: *nk.Context, y: nk.SymbolType, a: []const u8, alignment: nk.Flags) bool {
        return c.nk_combo_item_symbol_label(ctx, y, nk.slice(a), alignment) != 0;
    }

    pub fn close(ctx: *nk.Context) void {
        return c.nk_combo_close(ctx);
    }

    pub fn end(ctx: *nk.Context) void {
        return c.nk_combo_end(ctx);
    }

    test {
        std.testing.refAllDecls(@This());
    }
};

pub const rest = struct {
    test {
        std.testing.refAllDecls(@This());
    }

    pub fn nkContextualBegin(ctx: *nk.Context, y: nk.Flags, a: nk.Vec2, trigger_bounds: nk.Rect) bool {
        return c.nk_contextual_begin(ctx, y, a, trigger_bounds) != 0;
    }
    pub fn nkContextualItemLabel(ctx: *nk.Context, a: []const u8, @"align": nk.Flags) bool {
        return c.nk_contextual_item_label(ctx, nk.slice(a), @"align") != 0;
    }
    pub fn nkContextualItemImageLabel(ctx: *nk.Context, y: nk.Image, a: []const u8, alignment: nk.Flags) bool {
        return c.nk_contextual_item_image_label(ctx, y, nk.slice(a), alignment) != 0;
    }
    pub fn nkContextualItemSymbolLabel(ctx: *nk.Context, y: nk.SymbolType, a: []const u8, alignment: nk.Flags) bool {
        return c.nk_contextual_item_symbol_label(ctx, y, nk.slice(a), alignment) != 0;
    }
    pub fn nkContextualClose(ctx: *nk.Context) void {
        return c.nk_contextual_close(ctx);
    }
    pub fn nkContextualEnd(ctx: *nk.Context) void {
        return c.nk_contextual_end(ctx);
    }
    pub fn nkTooltip(ctx: *nk.Context, t: []const u8) void {
        return c.nk_tooltip(ctx, nk.slice(t));
    }
    pub fn nkTooltipBegin(ctx: *nk.Context, width: f32) bool {
        return c.nk_tooltip_begin(ctx, width) != 0;
    }
    pub fn nkTooltipEnd(ctx: *nk.Context) void {
        return c.nk_tooltip_end(ctx);
    }
    pub fn nkMenubarBegin(ctx: *nk.Context) void {
        return c.nk_menubar_begin(ctx);
    }
    pub fn nkMenubarEnd(ctx: *nk.Context) void {
        return c.nk_menubar_end(ctx);
    }
    pub fn nkMenuBeginLabel(ctx: *nk.Context, a: []const u8, @"align": nk.Flags, size: nk.Vec2) bool {
        return c.nk_menu_begin_label(ctx, nk.slice(a), @"align", size) != 0;
    }
    pub fn nkMenuBeginImage(ctx: *nk.Context, y: []const u8, a: nk.Image, size: nk.Vec2) bool {
        return c.nk_menu_begin_image(ctx, nk.slice(y), a, size) != 0;
    }
    pub fn nkMenuBeginImageLabel(ctx: *nk.Context, y: []const u8, @"align": nk.Flags, a: nk.Image, size: nk.Vec2) bool {
        return c.nk_menu_begin_image_label(ctx, nk.slice(y), @"align", a, size) != 0;
    }
    pub fn nkMenuBeginSymbol(ctx: *nk.Context, y: []const u8, a: nk.SymbolType, size: nk.Vec2) bool {
        return c.nk_menu_begin_symbol(ctx, nk.slice(y), a, size) != 0;
    }
    pub fn nkMenuBeginSymbolLabel(ctx: *nk.Context, y: []const u8, @"align": nk.Flags, a: nk.SymbolType, size: nk.Vec2) bool {
        return c.nk_menu_begin_symbol_label(ctx, nk.slice(y), @"align", a, size) != 0;
    }
    pub fn nkMenuItemLabel(ctx: *nk.Context, a: []const u8, alignment: nk.Flags) bool {
        return c.nk_menu_item_label(ctx, nk.slice(a), alignment) != 0;
    }
    pub fn nkMenuItemImageLabel(ctx: *nk.Context, y: nk.Image, a: []const u8, alignment: nk.Flags) bool {
        return c.nk_menu_item_image_label(ctx, y, nk.slice(a), alignment) != 0;
    }
    pub fn nkMenuItemSymbolLabel(ctx: *nk.Context, y: nk.SymbolType, a: []const u8, alignment: nk.Flags) bool {
        return c.nk_menu_item_symbol_label(ctx, y, nk.slice(a), alignment) != 0;
    }
    pub fn nkMenuClose(ctx: *nk.Context) void {
        return c.nk_menu_close(ctx);
    }
    pub fn nkMenuEnd(ctx: *nk.Context) void {
        return c.nk_menu_end(ctx);
    }
    pub fn nkStyleDefault(ctx: *nk.Context) void {
        return c.nk_style_default(ctx);
    }
    pub fn nkStyleFromTable(ctx: *nk.Context, u: [*c]const nk.Color) void {
        return c.nk_style_from_table(ctx, u);
    }
    pub fn nkStyleLoadCursor(ctx: *nk.Context, a: nk.StyleCursor, u: [*c]const nk.Cursor) void {
        return c.nk_style_load_cursor(ctx, a, u);
    }
    pub fn nkStyleLoadAllCursors(ctx: *nk.Context, u: [*c]nk.Cursor) void {
        return c.nk_style_load_all_cursors(ctx, u);
    }
    pub fn nkStyleGetColorByName(s: nk.StyleColors) [*c]const u8 {
        return c.nk_style_get_color_by_name(s);
    }
    pub fn nkStyleSetFont(ctx: *nk.Context, u: [*c]const nk.UserFont) void {
        return c.nk_style_set_font(ctx, u);
    }
    pub fn nkStyleSetCursor(ctx: *nk.Context, u: nk.StyleCursor) bool {
        return c.nk_style_set_cursor(ctx, u) != 0;
    }
    pub fn nkStyleShowCursor(ctx: *nk.Context) void {
        return c.nk_style_show_cursor(ctx);
    }
    pub fn nkStyleHideCursor(ctx: *nk.Context) void {
        return c.nk_style_hide_cursor(ctx);
    }
    pub fn nkStylePushFont(ctx: *nk.Context, u: [*c]const nk.UserFont) bool {
        return c.nk_style_push_font(ctx, u) != 0;
    }
    pub fn nkStylePushVec2(ctx: *nk.Context, a: [*c]nk.Vec2, u: nk.Vec2) bool {
        return c.nk_style_push_vec2(ctx, a, u) != 0;
    }
    pub fn nkStylePushStyleItem(ctx: *nk.Context, a: [*c]nk.StyleItem, u: nk.StyleItem) bool {
        return c.nk_style_push_style_item(ctx, a, u) != 0;
    }
    pub fn nkStylePushFlags(ctx: *nk.Context, a: [*c]nk.Flags, u: nk.Flags) bool {
        return c.nk_style_push_flags(ctx, a, u) != 0;
    }
    pub fn nkStylePushColor(ctx: *nk.Context, a: [*c]nk.Color, u: nk.Color) bool {
        return c.nk_style_push_color(ctx, a, u) != 0;
    }
    pub fn nkStylePopFont(ctx: *nk.Context) bool {
        return c.nk_style_pop_font(ctx) != 0;
    }
    pub fn nkStylePopFloat(ctx: *nk.Context) bool {
        return c.nk_style_pop_float(ctx) != 0;
    }
    pub fn nkStylePopVec2(ctx: *nk.Context) bool {
        return c.nk_style_pop_vec2(ctx) != 0;
    }
    pub fn nkStylePopStyleItem(ctx: *nk.Context) bool {
        return c.nk_style_pop_style_item(ctx) != 0;
    }
    pub fn nkStylePopFlags(ctx: *nk.Context) bool {
        return c.nk_style_pop_flags(ctx) != 0;
    }
    pub fn nkStylePopColor(ctx: *nk.Context) bool {
        return c.nk_style_pop_color(ctx) != 0;
    }
    pub fn nkRgb(r: c_int, g: c_int, b: c_int) nk.Color {
        return c.nk_rgb(r, g, b);
    }
    pub fn nkRgbIv(rgb: [*c]const c_int) nk.Color {
        return c.nk_rgb_iv(rgb);
    }
    pub fn nkRgbBv(rgb: [*c]const u8) nk.Color {
        return c.nk_rgb_bv(rgb);
    }
    pub fn nkRgbF(r: f32, g: f32, b: f32) nk.Color {
        return c.nk_rgb_f(r, g, b);
    }
    pub fn nkRgbFv(rgb: [*c]const f32) nk.Color {
        return c.nk_rgb_fv(rgb);
    }
    pub fn nkRgbCf(y: nk.Colorf) nk.Color {
        return c.nk_rgb_cf(y);
    }
    pub fn nkRgbHex(rgb: []const u8) nk.Color {
        return c.nk_rgb_hex(nk.slice(rgb));
    }
    pub fn nkRgba(r: c_int, g: c_int, b: c_int, a: c_int) nk.Color {
        return c.nk_rgba(r, g, b, a);
    }
    pub fn nkRgbaU32(i: c_uint) nk.Color {
        return c.nk_rgba_u32(i);
    }
    pub fn nkRgbaIv(rgba: [*c]const c_int) nk.Color {
        return c.nk_rgba_iv(rgba);
    }
    pub fn nkRgbaBv(rgba: [*c]const u8) nk.Color {
        return c.nk_rgba_bv(rgba);
    }
    pub fn nkRgbaF(r: f32, g: f32, b: f32, a: f32) nk.Color {
        return c.nk_rgba_f(r, g, b, a);
    }
    pub fn nkRgbaFv(rgba: [*c]const f32) nk.Color {
        return c.nk_rgba_fv(rgba);
    }
    pub fn nkRgbaCf(y: nk.Colorf) nk.Color {
        return c.nk_rgba_cf(y);
    }
    pub fn nkRgbaHex(rgb: []const u8) nk.Color {
        return c.nk_rgba_hex(nk.slice(rgb));
    }
    pub fn nkHsvaColorf(h: f32, s: f32, v: f32, a: f32) nk.Colorf {
        return c.nk_hsva_colorf(h, s, v, a);
    }
    pub fn nkHsvaColorfv(y: [*c]f32) nk.Colorf {
        return c.nk_hsva_colorfv(y);
    }
    pub fn nkColorfHsvaF(out_h: [*c]f32, out_s: [*c]f32, out_v: [*c]f32, out_a: [*c]f32, in: nk.Colorf) void {
        return c.nk_colorf_hsva_f(out_h, out_s, out_v, out_a, in);
    }
    pub fn nkColorfHsvaFv(hsva: [*c]f32, in: nk.Colorf) void {
        return c.nk_colorf_hsva_fv(hsva, in);
    }
    pub fn nkHsv(h: c_int, s: c_int, v: c_int) nk.Color {
        return c.nk_hsv(h, s, v);
    }
    pub fn nkHsvIv(hsv: [*c]const c_int) nk.Color {
        return c.nk_hsv_iv(hsv);
    }
    pub fn nkHsvBv(hsv: [*c]const u8) nk.Color {
        return c.nk_hsv_bv(hsv);
    }
    pub fn nkHsvF(h: f32, s: f32, v: f32) nk.Color {
        return c.nk_hsv_f(h, s, v);
    }
    pub fn nkHsvFv(hsv: [*c]const f32) nk.Color {
        return c.nk_hsv_fv(hsv);
    }
    pub fn nkHsva(h: c_int, s: c_int, v: c_int, a: c_int) nk.Color {
        return c.nk_hsva(h, s, v, a);
    }
    pub fn nkHsvaIv(hsva: [*c]const c_int) nk.Color {
        return c.nk_hsva_iv(hsva);
    }
    pub fn nkHsvaBv(hsva: [*c]const u8) nk.Color {
        return c.nk_hsva_bv(hsva);
    }
    pub fn nkHsvaF(h: f32, s: f32, v: f32, a: f32) nk.Color {
        return c.nk_hsva_f(h, s, v, a);
    }
    pub fn nkHsvaFv(hsva: [*c]const f32) nk.Color {
        return c.nk_hsva_fv(hsva);
    }
    pub fn nkColorF(r: [*c]f32, g: [*c]f32, b: [*c]f32, a: [*c]f32, u: nk.Color) void {
        return c.nk_color_f(r, g, b, a, u);
    }
    pub fn nkColorFv(rgba_out: [*c]f32, u: nk.Color) void {
        return c.nk_color_fv(rgba_out, u);
    }
    pub fn nkColorCf(y: nk.Color) nk.Colorf {
        return c.nk_color_cf(y);
    }
    pub fn nkColorD(r: [*c]f64, g: [*c]f64, b: [*c]f64, a: [*c]f64, u: nk.Color) void {
        return c.nk_color_d(r, g, b, a, u);
    }
    pub fn nkColorDv(rgba_out: [*c]f64, u: nk.Color) void {
        return c.nk_color_dv(rgba_out, u);
    }
    pub fn nkColorU32(y: nk.Color) c.nk_uint {
        return c.nk_color_u32(y);
    }
    pub fn nkColorHexRgba(output: [*c]u8, u: nk.Color) void {
        return c.nk_color_hex_rgba(output, u);
    }
    pub fn nkColorHexRgb(output: [*c]u8, u: nk.Color) void {
        return c.nk_color_hex_rgb(output, u);
    }
    pub fn nkColorHsvI(out_h: [*c]c_int, out_s: [*c]c_int, out_v: [*c]c_int, u: nk.Color) void {
        return c.nk_color_hsv_i(out_h, out_s, out_v, u);
    }
    pub fn nkColorHsvB(out_h: [*c]u8, out_s: [*c]u8, out_v: [*c]u8, u: nk.Color) void {
        return c.nk_color_hsv_b(out_h, out_s, out_v, u);
    }
    pub fn nkColorHsvIv(hsv_out: [*c]c_int, u: nk.Color) void {
        return c.nk_color_hsv_iv(hsv_out, u);
    }
    pub fn nkColorHsvBv(hsv_out: [*c]u8, u: nk.Color) void {
        return c.nk_color_hsv_bv(hsv_out, u);
    }
    pub fn nkColorHsvF(out_h: [*c]f32, out_s: [*c]f32, out_v: [*c]f32, u: nk.Color) void {
        return c.nk_color_hsv_f(out_h, out_s, out_v, u);
    }
    pub fn nkColorHsvFv(hsv_out: [*c]f32, u: nk.Color) void {
        return c.nk_color_hsv_fv(hsv_out, u);
    }
    pub fn nkColorHsvaI(h: [*c]c_int, s: [*c]c_int, v: [*c]c_int, a: [*c]c_int, u: nk.Color) void {
        return c.nk_color_hsva_i(h, s, v, a, u);
    }
    pub fn nkColorHsvaB(h: [*c]u8, s: [*c]u8, v: [*c]u8, a: [*c]u8, u: nk.Color) void {
        return c.nk_color_hsva_b(h, s, v, a, u);
    }
    pub fn nkColorHsvaIv(hsva_out: [*c]c_int, u: nk.Color) void {
        return c.nk_color_hsva_iv(hsva_out, u);
    }
    pub fn nkColorHsvaBv(hsva_out: [*c]u8, u: nk.Color) void {
        return c.nk_color_hsva_bv(hsva_out, u);
    }
    pub fn nkColorHsvaF(out_h: [*c]f32, out_s: [*c]f32, out_v: [*c]f32, out_a: [*c]f32, u: nk.Color) void {
        return c.nk_color_hsva_f(out_h, out_s, out_v, out_a, u);
    }
    pub fn nkColorHsvaFv(hsva_out: [*c]f32, u: nk.Color) void {
        return c.nk_color_hsva_fv(hsva_out, u);
    }
    pub fn nkHandlePtr(ptr: ?*c_void) nk.Handle {
        return c.nk_handle_ptr(ptr);
    }
    pub fn nkHandleId(h: c_int) nk.Handle {
        return c.nk_handle_id(h);
    }
    pub fn nkImageHandle(h: nk.Handle) nk.Image {
        return c.nk_image_handle(h);
    }
    pub fn nkImagePtr(ptr: ?*c_void) nk.Image {
        return c.nk_image_ptr(ptr);
    }
    pub fn nkImageId(id: c_int) nk.Image {
        return c.nk_image_id(id);
    }
    pub fn nkImageIsSubimage(img: [*c]const nk.Image) bool {
        return c.nk_image_is_subimage(img) != 0;
    }
    pub fn nkSubimagePtr(ptr: ?*c_void, w: c_ushort, h: c_ushort, sub_region: nk.Rect) nk.Image {
        return c.nk_subimage_ptr(ptr, w, h, sub_region);
    }
    pub fn nkSubimageId(id: c_int, w: c_ushort, h: c_ushort, sub_region: nk.Rect) nk.Image {
        return c.nk_subimage_id(id, w, h, sub_region);
    }
    pub fn nkSubimageHandle(h: nk.Handle, w: c_ushort, q: c_ushort, sub_region: nk.Rect) nk.Image {
        return c.nk_subimage_handle(h, w, q, sub_region);
    }
    pub fn nkMurmurHash(key: []const u8, seed: nk.Hash) nk.Hash {
        return c.nk_murmur_hash(nk.slice(key), seed);
    }
    pub fn nkTriangleFromDirection(result: [*c]nk.Vec2, r: nk.Rect, pad_x: f32, pad_y: f32, u: nk.Heading) void {
        return c.nk_triangle_from_direction(result, r, pad_x, pad_y, u);
    }
    pub fn nkVec2(x: f32, y: f32) nk.Vec2 {
        return c.nk_vec2(x, y);
    }
    pub fn nkVec2i(x: c_int, y: c_int) nk.Vec2 {
        return c.nk_vec2i(x, y);
    }
    pub fn nkVec2v(xy: [*c]const f32) nk.Vec2 {
        return c.nk_vec2v(xy);
    }
    pub fn nkVec2iv(xy: [*c]const c_int) nk.Vec2 {
        return c.nk_vec2iv(xy);
    }
    pub fn nkGetNullRect() nk.Rect {
        return c.nk_get_null_rect();
    }
    pub fn nkRect(x: f32, y: f32, w: f32, h: f32) nk.Rect {
        return c.nk_rect(x, y, w, h);
    }
    pub fn nkRecti(x: c_int, y: c_int, w: c_int, h: c_int) nk.Rect {
        return c.nk_recti(x, y, w, h);
    }
    pub fn nkRecta(pos: nk.Vec2, size: nk.Vec2) nk.Rect {
        return c.nk_recta(pos, size);
    }
    pub fn nkRectv(xywh: [*c]const f32) nk.Rect {
        return c.nk_rectv(xywh);
    }
    pub fn nkRectiv(xywh: [*c]const c_int) nk.Rect {
        return c.nk_rectiv(xywh);
    }
    pub fn nkRectPos(r: nk.Rect) nk.Vec2 {
        return c.nk_rect_pos(r);
    }
    pub fn nkRectSize(r: nk.Rect) nk.Vec2 {
        return c.nk_rect_size(r);
    }
    pub fn nkFontDefaultGlyphRanges() [*c]const nk.Rune {
        return c.nk_font_default_glyph_ranges();
    }
    pub fn nkFontChineseGlyphRanges() [*c]const nk.Rune {
        return c.nk_font_chinese_glyph_ranges();
    }
    pub fn nkFontCyrillicGlyphRanges() [*c]const nk.Rune {
        return c.nk_font_cyrillic_glyph_ranges();
    }
    pub fn nkFontKoreanGlyphRanges() [*c]const nk.Rune {
        return c.nk_font_korean_glyph_ranges();
    }
    pub fn nkBufferInit(b: [*c]nk.Buffer, a: [*c]const nk.Allocator, size: usize) void {
        return c.nk_buffer_init(b, a, size);
    }
    pub fn nkBufferInitFixed(b: [*c]nk.Buffer, memory: ?*c_void, size: usize) void {
        return c.nk_buffer_init_fixed(b, memory, size);
    }
    pub fn nkBufferInfo(m: [*c]nk.MemoryStatus, b: [*c]nk.Buffer) void {
        return c.nk_buffer_info(m, b);
    }
    pub fn nkBufferPush(b: [*c]nk.Buffer, t: nk.BufferAllocatorType, memory: ?*const c_void, size: usize, @"align": usize) void {
        return c.nk_buffer_push(b, t, memory, size, @"align");
    }
    pub fn nkBufferMark(b: [*c]nk.Buffer, t: nk.BufferAllocatorType) void {
        return c.nk_buffer_mark(b, t);
    }
    pub fn nkBufferReset(b: [*c]nk.Buffer, t: nk.BufferAllocatorType) void {
        return c.nk_buffer_reset(b, t);
    }
    pub fn nkBufferClear(b: [*c]nk.Buffer) void {
        return c.nk_buffer_clear(b);
    }
    pub fn nkBufferFree(b: [*c]nk.Buffer) void {
        return c.nk_buffer_free(b);
    }
    pub fn nkBufferMemory(b: [*c]nk.Buffer) ?*c_void {
        return c.nk_buffer_memory(b);
    }
    pub fn nkBufferMemoryConst(b: [*c]const nk.Buffer) ?*const c_void {
        return c.nk_buffer_memory_const(b);
    }
    pub fn nkBufferTotal(b: [*c]nk.Buffer) usize {
        return c.nk_buffer_total(b);
    }
    pub fn nkStrInit(s: [*c]nk.String, a: [*c]const nk.Allocator, size: usize) void {
        return c.nk_str_init(s, a, size);
    }
    pub fn nkStrInitFixed(s: [*c]nk.String, memory: ?*c_void, size: usize) void {
        return c.nk_str_init_fixed(s, memory, size);
    }
    pub fn nkStrClear(s: [*c]nk.String) void {
        return c.nk_str_clear(s);
    }
    pub fn nkStrFree(s: [*c]nk.String) void {
        return c.nk_str_free(s);
    }
    pub fn nkStrAppendStrChar(s: [*c]nk.String, t: []const u8) c_int {
        return c.nk_str_append_str_char(s, nk.slice(t));
    }
    pub fn nkStrAppendStrRunes(s: [*c]nk.String, runes: [*c]const nk.Rune, len: usize) c_int {
        return c.nk_str_append_str_runes(s, runes, len);
    }
    pub fn nkStrInsertAtChar(s: [*c]nk.String, pos: c_int, t: []const u8) c_int {
        return c.nk_str_insert_at_char(s, pos, nk.slice(t));
    }
    pub fn nkStrInsertAtRune(s: [*c]nk.String, pos: c_int, t: []const u8) c_int {
        return c.nk_str_insert_at_rune(s, pos, nk.slice(t));
    }
    pub fn nkStrInsertTextRunes(s: [*c]nk.String, pos: c_int, a: [*c]const nk.Rune, u: c_int) c_int {
        return c.nk_str_insert_text_runes(s, pos, a, u);
    }
    pub fn nkStrInsertStrRunes(s: [*c]nk.String, pos: c_int, a: [*c]const nk.Rune) c_int {
        return c.nk_str_insert_str_runes(s, pos, a);
    }
    pub fn nkStrRemoveChars(s: [*c]nk.String, len: c_int) void {
        return c.nk_str_remove_chars(s, len);
    }
    pub fn nkStrRemoveRunes(s: [*c]nk.String, len: c_int) void {
        return c.nk_str_remove_runes(s, len);
    }
    pub fn nkStrDeleteChars(s: [*c]nk.String, pos: c_int, len: c_int) void {
        return c.nk_str_delete_chars(s, pos, len);
    }
    pub fn nkStrDeleteRunes(s: [*c]nk.String, pos: c_int, len: c_int) void {
        return c.nk_str_delete_runes(s, pos, len);
    }
    pub fn nkStrAtChar(s: [*c]nk.String, pos: c_int) [*c]u8 {
        return c.nk_str_at_char(s, pos);
    }
    pub fn nkStrAtRune(s: [*c]nk.String, pos: c_int, unicode: [*c]nk.Rune, len: [*c]c_int) [*c]u8 {
        return c.nk_str_at_rune(s, pos, unicode, len);
    }
    pub fn nkStrRuneAt(s: [*c]const nk.String, pos: c_int) nk.Rune {
        return c.nk_str_rune_at(s, pos);
    }
    pub fn nkStrAtCharConst(s: [*c]const nk.String, pos: c_int) [*c]const u8 {
        return c.nk_str_at_char_const(s, pos);
    }
    pub fn nkStrAtConst(s: [*c]const nk.String, pos: c_int, unicode: [*c]nk.Rune) []const u8 {
        const res = c.nk_str_at_const(s, pos, unicode);
        return res.ptr[0..res.len];
    }
    pub fn nkStrGet(s: [*c]nk.String) [*c]u8 {
        return c.nk_str_get(s);
    }
    pub fn nkStrGetConst(s: [*c]const nk.String) []const u8 {
        const res = c.nk_str_get_const(s);
        return res.ptr[0..res.len];
    }

    pub fn nkStrLen(s: [*c]nk.String) c_int {
        return c.nk_str_len(s);
    }

    pub fn nkFilterDefault(t: [*c]const nk.TextEdit, unicode: nk.Rune) bool {
        return c.nk_filter_default(t, unicode) != 0;
    }
    pub fn nkFilterAscii(t: [*c]const nk.TextEdit, unicode: nk.Rune) bool {
        return c.nk_filter_ascii(t, unicode) != 0;
    }
    pub fn nkFilterFloat(t: [*c]const nk.TextEdit, unicode: nk.Rune) bool {
        return c.nk_filter_float(t, unicode) != 0;
    }
    pub fn nkFilterDecimal(t: [*c]const nk.TextEdit, unicode: nk.Rune) bool {
        return c.nk_filter_decimal(t, unicode) != 0;
    }
    pub fn nkFilterHex(t: [*c]const nk.TextEdit, unicode: nk.Rune) bool {
        return c.nk_filter_hex(t, unicode) != 0;
    }
    pub fn nkFilterOct(t: [*c]const nk.TextEdit, unicode: nk.Rune) bool {
        return c.nk_filter_oct(t, unicode) != 0;
    }
    pub fn nkFilterBinary(t: [*c]const nk.TextEdit, unicode: nk.Rune) bool {
        return c.nk_filter_binary(t, unicode) != 0;
    }
    pub fn nkTexteditInit(e: [*c]nk.TextEdit, a: [*c]nk.Allocator, size: usize) void {
        return c.nk_textedit_init(e, a, size);
    }
    pub fn nkTexteditInitFixed(e: [*c]nk.TextEdit, memory: ?*c_void, size: usize) void {
        return c.nk_textedit_init_fixed(e, memory, size);
    }
    pub fn nkTexteditFree(e: [*c]nk.TextEdit) void {
        return c.nk_textedit_free(e);
    }
    pub fn nkTexteditText(e: [*c]nk.TextEdit, t: []const u8) void {
        return c.nk_textedit_text(e, nk.slice(t));
    }
    pub fn nkTexteditDelete(e: [*c]nk.TextEdit, where: c_int, len: c_int) void {
        return c.nk_textedit_delete(e, where, len);
    }
    pub fn nkTexteditDeleteSelection(e: [*c]nk.TextEdit) void {
        return c.nk_textedit_delete_selection(e);
    }
    pub fn nkTexteditSelectAll(e: [*c]nk.TextEdit) void {
        return c.nk_textedit_select_all(e);
    }
    pub fn nkTexteditCut(e: [*c]nk.TextEdit) bool {
        return c.nk_textedit_cut(e) != 0;
    }
    pub fn nkTexteditPaste(e: [*c]nk.TextEdit, t: []const u8) bool {
        return c.nk_textedit_paste(e, nk.slice(t)) != 0;
    }
    pub fn nkTexteditUndo(e: [*c]nk.TextEdit) void {
        return c.nk_textedit_undo(e);
    }
    pub fn nkTexteditRedo(e: [*c]nk.TextEdit) void {
        return c.nk_textedit_redo(e);
    }

    pub fn nkStrokeLine(b: [*c]nk.CommandBuffer, x0: f32, y0: f32, x1: f32, y1: f32, line_thickness: f32, u: nk.Color) void {
        return c.nk_stroke_line(b, x0, y0, x1, y1, line_thickness, u);
    }
    pub fn nkStrokeCurve(b: [*c]nk.CommandBuffer, x0: f32, y0: f32, x1: f32, y1: f32, line_thichness: f32, d: f32, y: f32, a: f32, line_thickness: f32, u: nk.Color) void {
        return c.nk_stroke_curve(b, x0, y0, x1, y1, line_thichness, d, y, a, line_thickness, u);
    }
    pub fn nkStrokeRect(b: [*c]nk.CommandBuffer, r: nk.Rect, rounding: f32, line_thickness: f32, a: nk.Color) void {
        return c.nk_stroke_rect(b, r, rounding, line_thickness, a);
    }
    pub fn nkStrokeCircle(b: [*c]nk.CommandBuffer, r: nk.Rect, line_thickness: f32, u: nk.Color) void {
        return c.nk_stroke_circle(b, r, line_thickness, u);
    }
    pub fn nkStrokeArc(b: [*c]nk.CommandBuffer, cx: f32, cy: f32, radius: f32, a_min: f32, a_max: f32, line_thickness: f32, u: nk.Color) void {
        return c.nk_stroke_arc(b, cx, cy, radius, a_min, a_max, line_thickness, u);
    }
    pub fn nkStrokeTriangle(b: [*c]nk.CommandBuffer, h: f32, o: f32, q: f32, d: f32, y: f32, a: f32, line_thichness: f32, u: nk.Color) void {
        return c.nk_stroke_triangle(b, h, o, q, d, y, a, line_thichness, u);
    }
    pub fn nkStrokePolyline(b: [*c]nk.CommandBuffer, points: [*c]f32, point_count: c_int, line_thickness: f32, col: nk.Color) void {
        return c.nk_stroke_polyline(b, points, point_count, line_thickness, col);
    }
    pub fn nkStrokePolygon(b: [*c]nk.CommandBuffer, f: [*c]f32, point_count: c_int, line_thickness: f32, a: nk.Color) void {
        return c.nk_stroke_polygon(b, f, point_count, line_thickness, a);
    }
    pub fn nkFillRect(b: [*c]nk.CommandBuffer, r: nk.Rect, rounding: f32, u: nk.Color) void {
        return c.nk_fill_rect(b, r, rounding, u);
    }
    pub fn nkFillRectMultiColor(b: [*c]nk.CommandBuffer, r: nk.Rect, left: nk.Color, top: nk.Color, right: nk.Color, bottom: nk.Color) void {
        return c.nk_fill_rect_multi_color(b, r, left, top, right, bottom);
    }
    pub fn nkFillCircle(b: [*c]nk.CommandBuffer, r: nk.Rect, a: nk.Color) void {
        return c.nk_fill_circle(b, r, a);
    }
    pub fn nkFillArc(b: [*c]nk.CommandBuffer, cx: f32, cy: f32, radius: f32, a_min: f32, a_max: f32, u: nk.Color) void {
        return c.nk_fill_arc(b, cx, cy, radius, a_min, a_max, u);
    }
    pub fn nkFillTriangle(b: [*c]nk.CommandBuffer, x0: f32, y0: f32, x1: f32, y1: f32, x2: f32, y2: f32, u: nk.Color) void {
        return c.nk_fill_triangle(b, x0, y0, x1, y1, x2, y2, u);
    }
    pub fn nkFillPolygon(b: [*c]nk.CommandBuffer, a: [*c]f32, point_count: c_int, u: nk.Color) void {
        return c.nk_fill_polygon(b, a, point_count, u);
    }
    pub fn nkDrawImage(b: [*c]nk.CommandBuffer, r: nk.Rect, y: [*c]const nk.Image, a: nk.Color) void {
        return c.nk_draw_image(b, r, y, a);
    }
    pub fn nkDrawText(b: [*c]nk.CommandBuffer, r: nk.Rect, t: []const u8, d: [*c]const nk.UserFont, y: nk.Color, q: nk.Color) void {
        return c.nk_draw_text(b, r, nk.slice(t), d, y, q);
    }
    pub fn nkPushScissor(b: [*c]nk.CommandBuffer, r: nk.Rect) void {
        return c.nk_push_scissor(b, r);
    }
    pub fn nkPushCustom(b: [*c]nk.CommandBuffer, r: nk.Rect, a: nk.CustomCallback, usr: nk.Handle) void {
        return c.nk_push_custom(b, r, a, usr);
    }
    pub fn nkInputHasMouseClick(in: *const nk.Input, bots: nk.Buttons) bool {
        return c.nk_input_has_mouse_click(in, bots) != 0;
    }
    pub fn nkInputHasMouseClickInRect(in: *const nk.Input, bots: nk.Buttons, r: nk.Rect) bool {
        return c.nk_input_has_mouse_click_in_rect(in, bots, r) != 0;
    }
    pub fn nkInputHasMouseClickDownInRect(in: *const nk.Input, bots: nk.Buttons, r: nk.Rect, down: bool) bool {
        return c.nk_input_has_mouse_click_down_in_rect(in, bots, r, @boolToInt(down)) != 0;
    }
    pub fn nkInputIsMouseClickInRect(in: *const nk.Input, bots: nk.Buttons, r: nk.Rect) bool {
        return c.nk_input_is_mouse_click_in_rect(in, bots, r) != 0;
    }
    pub fn nkInputIsMouseClickDownInRect(in: *const nk.Input, id: nk.Buttons, b: nk.Rect, down: bool) bool {
        return c.nk_input_is_mouse_click_down_in_rect(in, id, b, @boolToInt(down)) != 0;
    }
    pub fn nkInputAnyMouseClickInRect(in: *const nk.Input, r: nk.Rect) bool {
        return c.nk_input_any_mouse_click_in_rect(in, r) != 0;
    }
    pub fn nkInputIsMousePrevHoveringRect(in: *const nk.Input, r: nk.Rect) bool {
        return c.nk_input_is_mouse_prev_hovering_rect(in, r) != 0;
    }
    pub fn nkInputIsMouseHoveringRect(in: *const nk.Input, r: nk.Rect) bool {
        return c.nk_input_is_mouse_hovering_rect(in, r) != 0;
    }
    pub fn nkInputMouseClicked(in: *const nk.Input, bots: nk.Buttons, r: nk.Rect) bool {
        return c.nk_input_mouse_clicked(in, bots, r) != 0;
    }
    pub fn nkInputIsMouseDown(in: *const nk.Input, bots: nk.Buttons) bool {
        return c.nk_input_is_mouse_down(in, bots) != 0;
    }
    pub fn nkInputIsMousePressed(in: *const nk.Input, bots: nk.Buttons) bool {
        return c.nk_input_is_mouse_pressed(in, bots) != 0;
    }
    pub fn nkInputIsMouseReleased(in: *const nk.Input, bots: nk.Buttons) bool {
        return c.nk_input_is_mouse_released(in, bots) != 0;
    }
    pub fn nkInputIsKeyPressed(in: *const nk.Input, keys: nk.Keys) bool {
        return c.nk_input_is_key_pressed(in, keys) != 0;
    }
    pub fn nkInputIsKeyReleased(in: *const nk.Input, keys: nk.Keys) bool {
        return c.nk_input_is_key_released(in, keys) != 0;
    }
    pub fn nkInputIsKeyDown(in: *const nk.Input, keys: nk.Keys) bool {
        return c.nk_input_is_key_down(in, keys) != 0;
    }
    pub fn nkStyleItemImage(img: nk.Image) nk.StyleItem {
        return c.nk_style_item_image(img);
    }
    pub fn nkStyleItemColor(y: nk.Color) nk.StyleItem {
        return c.nk_style_item_color(y);
    }
    pub fn nkStyleItemHide() nk.StyleItem {
        return c.nk_style_item_hide();
    }
};

pub const Allocator = c.struct_nk_allocator;
pub const Buffer = c.struct_nk_buffer;
pub const BufferAllocatorType = c.enum_nk_buffer_allocation_type;
pub const Buttons = c.nk_buttons;
pub const ChartType = c.enum_nk_chart_type;
pub const CollapseStates = c.nk_collapse_states;
pub const Color = c.struct_nk_color;
pub const Colorf = c.struct_nk_colorf;
pub const Command = c.struct_nk_command;
pub const CommandBuffer = c.struct_nk_command_buffer;
pub const Context = c.struct_nk_context;
pub const Cursor = c.struct_nk_cursor;
pub const CustomCallback = c.nk_command_custom_callback;
pub const Filter = c.nk_plugin_filter;
pub const Flags = c.nk_flags;
pub const FontAtlas = c.struct_nk_font_atlas;
pub const Handle = c.nk_handle;
pub const Hash = c.nk_hash;
pub const Heading = c.enum_nk_heading;
pub const Image = c.struct_nk_image;
pub const Input = c.struct_nk_input;
pub const Keys = c.nk_keys;
pub const MemoryStatus = c.struct_nk_memory_status;
pub const PopupType = c.enum_nk_popup_type;
pub const Rect = c.struct_nk_rect;
pub const Rune = c.nk_rune;
pub const Scroll = c.struct_nk_scroll;
pub const Slice = c.struct_nk_slice;
pub const String = c.struct_nk_str;
pub const StyleButton = c.struct_nk_style_button;
pub const StyleColors = c.enum_nk_style_colors;
pub const StyleCursor = c.enum_nk_style_cursor;
pub const StyleItem = c.struct_nk_style_item;
pub const SymbolType = c.nk_symbol_type;
pub const TextEdit = c.struct_nk_text_edit;
pub const UserFont = c.struct_nk_user_font;
pub const Vec2 = c.struct_nk_vec2;
pub const Window = c.struct_nk_window;

pub const ScrollOffset = struct {
    x: usize,
    y: usize,
};

pub fn init(alloc: *mem.Allocator, font: *const UserFont) Context {
    var res: Context = undefined;
    const status = c.nk_init(&res, &allocator(alloc), font);

    // init only returns `0` if we pass `null` as the allocator.
    debug.assert(status != 0);
    return res;
}

pub fn initFixed(buf: []u8, font: *const UserFont) Context {
    var res: Context = undefined;
    const status = c.nk_init_fixed(&res, buf.ptr, buf.len, font);

    // init only returns `0` if we pass `null` as the buffer.
    debug.assert(status != 0);
    return res;
}
// pub fn initCustom(cmds: *Buffer, pool: *Buffer, font: Font) Context {}

pub fn clear(ctx: *Context) void {
    c.nk_clear(ctx);
}

pub fn free(ctx: *Context) void {
    c.nk_free(ctx);
}

pub fn begin(ctx: *Context) ?*const Command {
    return c.nk__begin(ctx);
}

pub fn next(ctx: *Context, prev: ?*const Command) ?*const Command {
    return c.nk__next(ctx, prev);
}

pub fn slice(s: []const u8) Slice {
    return .{
        .ptr = s.ptr,
        .len = s.len,
        ._pad = undefined,
    };
}

pub fn rect(x: f32, y: f32, w: f32, h: f32) Rect {
    return .{ .x = x, .y = y, .w = w, .h = h, ._pad = undefined };
}

pub fn vec2(x: f32, y: f32) Vec2 {
    return .{ .x = x, .y = y, ._pad = undefined, ._pad2 = undefined };
}

pub fn typeId(comptime T: type) usize {
    // We generate a completly unique id by declaring a global variable `id`, and storing
    // the address if `id` in itself.
    const Id = struct {
        var addr: u8 = undefined;
    };
    return @ptrToInt(&Id.addr);
}

pub fn allocator(alloc: *mem.Allocator) Allocator {
    return .{
        .userdata = .{ .ptr = @ptrCast(*c_void, alloc) },
        .alloc = heap.alloc,
        .free = heap.free,
    };
}

fn DiscardConst(comptime Ptr: type) type {
    var info = @typeInfo(Ptr);
    info.Pointer.is_const = false;
    return @Type(info);
}

fn discardConst(ptr: anytype) DiscardConst(@TypeOf(ptr)) {
    const Res = DiscardConst(@TypeOf(ptr));
    return @intToPtr(Res, @ptrToInt(ptr));
}

const heap = struct {
    // Nuklears allocator interface does not send back and forth the size of the allocation.
    // This is a problem, as zigs interface really wants you to pass back the size when
    // reallocating and freeing. To solve this, we store the size in a header block that is
    // stored in the memory before the pointer we return to nuklear.
    const header_align = @alignOf(Header);
    const header_size = @sizeOf(Header);
    const Header = struct {
        size: usize,
    };

    fn alloc(handle: Handle, m_old: ?*c_void, n: c.nk_size) callconv(.C) ?*c_void {
        const old = if (@ptrCast(?[*]u8, m_old)) |old| blk: {
            const old_with_header = old - header_size;
            const header = alignPtrCast([*]Header, old_with_header)[0];

            break :blk old_with_header[0 .. header_size + header.size];
        } else &[_]u8{};

        if (n == 0) {
            free(handle, m_old);
            return null;
        }

        const al = alignPtrCast(*mem.Allocator, handle.ptr);
        const res = al.reallocAdvanced(old, header_align, n + header_size, .exact) catch
            return null;

        // Store the size of the allocation in the extra memory we allocated, and return
        // a pointer after the header.
        @ptrCast([*]Header, res.ptr)[0] = .{ .size = n };
        return @ptrCast(*c_void, res[header_size..].ptr);
    }

    fn free(handle: Handle, m_old: ?*c_void) callconv(.C) void {
        const old = @ptrCast(?[*]u8, m_old) orelse return;
        const old_with_header = old - header_size;
        const header = alignPtrCast([*]Header, old_with_header)[0];

        const al = alignPtrCast(*mem.Allocator, handle.ptr);
        al.free(old_with_header[0 .. header_size + header.size]);
    }

    fn alignPtrCast(comptime Ptr: type, ptr: anytype) Ptr {
        return @ptrCast(Ptr, @alignCast(@typeInfo(Ptr).Pointer.alignment, ptr));
    }
};

test {
    std.testing.refAllDecls(@This());
}

test "initFixed" {
    var font: UserFont = undefined;
    var buf: [1024]u8 = undefined;
    var ctx = &initFixed(&buf, &font);
    defer free(ctx);
}

// test "Context.initCustom" {
//     var ctx = Context.initCustom(&buf, null);
//     defer ctx.free();
// }
//
