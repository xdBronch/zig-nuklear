const c = @import("c.zig");
const nk = @import("../nuklear.zig");
const std = @import("std");

const testing = std.testing;

pub const Text = c.nk_text_edit;

pub const Flags = struct {
    read_only: bool = false,
    auto_select: bool = false,
    sig_enter: bool = false,
    allow_tab: bool = false,
    no_cursor: bool = false,
    selectable: bool = false,
    clipboard: bool = false,
    ctrl_enter_newline: bool = false,
    no_horizontal_scroll: bool = false,
    always_insert_mode: bool = false,
    multiline: bool = false,
    goto_end_on_activate: bool = false,

    fn toNulkear(flags: Flags) nk.Flags {
        return @as(nk.Flags, @intCast((c.NK_EDIT_READ_ONLY * @intFromBool(flags.read_only)) |
            (c.NK_EDIT_AUTO_SELECT * @intFromBool(flags.auto_select)) |
            (c.NK_EDIT_SIG_ENTER * @intFromBool(flags.sig_enter)) |
            (c.NK_EDIT_ALLOW_TAB * @intFromBool(flags.allow_tab)) |
            (c.NK_EDIT_NO_CURSOR * @intFromBool(flags.no_cursor)) |
            (c.NK_EDIT_SELECTABLE * @intFromBool(flags.selectable)) |
            (c.NK_EDIT_CLIPBOARD * @intFromBool(flags.clipboard)) |
            (c.NK_EDIT_CTRL_ENTER_NEWLINE * @intFromBool(flags.ctrl_enter_newline)) |
            (c.NK_EDIT_NO_HORIZONTAL_SCROLL * @intFromBool(flags.no_horizontal_scroll)) |
            (c.NK_EDIT_ALWAYS_INSERT_MODE * @intFromBool(flags.always_insert_mode)) |
            (c.NK_EDIT_MULTILINE * @intFromBool(flags.multiline)) |
            (c.NK_EDIT_GOTO_END_ON_ACTIVATE * @intFromBool(flags.goto_end_on_activate))));
    }

    pub const simple = Flags{ .always_insert_mode = true };
    pub const field = Flags{
        .always_insert_mode = true,
        .selectable = true,
        .clipboard = true,
    };
    pub const box = Flags{
        .always_insert_mode = true,
        .selectable = true,
        .clipboard = true,
        .multiline = true,
        .allow_tab = true,
    };
    pub const editor = Flags{
        .selectable = true,
        .multiline = true,
        .allow_tab = true,
        .clipboard = true,
    };
};

pub const Options = struct {
    filter: nk.Filter = c.nk_filter_default,
    flags: Flags = Flags{},
};

pub fn string(
    ctx: *nk.Context,
    buf: *[]u8,
    max: usize,
    opts: Options,
) nk.Flags {
    var c_len = @as(c_int, @intCast(buf.len));
    defer buf.len = @as(usize, @intCast(c_len));
    return c.nk_edit_string(
        ctx,
        opts.flags.toNulkear(),
        buf.ptr,
        &c_len,
        @as(c_int, @intCast(max)),
        opts.filter,
    );
}

pub fn stringZ(
    ctx: *nk.Context,
    buf: [*:0]u8,
    max: usize,
    opts: Options,
) nk.Flags {
    return c.nk_edit_string_zero_terminated(
        ctx,
        opts.flags.toNulkear(),
        buf,
        @as(c_int, @intCast(max)),
        opts.filter,
    );
}

pub fn buffer(ctx: *nk.Context, t: *Text, opts: Options) nk.Flags {
    return c.nk_edit_buffer(ctx, opts.flags.toNulkear(), t, opts.filter);
}

pub fn focus(ctx: *nk.Context, flags: nk.Flags) void {
    return c.nk_edit_focus(ctx, flags);
}

pub fn unfocus(ctx: *nk.Context) void {
    return c.nk_edit_unfocus(ctx);
}

test {
    testing.refAllDecls(@This());
}
