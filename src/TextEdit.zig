const c = @import("c.zig");
const nk = @import("../nuklear.zig");
const std = @import("std");

const mem = std.mem;
const testing = std.testing;

const TextEdit = @This();

c: c.struct_nk_text_edit,

pub fn init(a: mem.Allocator, size: usize) TextEdit {
    var res: TextEdit = undefined;
    c.nk_textedit_init(
        &res.c,
        &nk.allocator(a),
        @as(c.nk_size, @intCast(size)),
    );
    return res;
}

pub fn initFixed(memory: []u8) TextEdit {
    var res: TextEdit = undefined;
    c.nk_textedit_init_fixed(
        &res.c,
        @as(*anyopaque, @ptrCast(memory.ptr)),
        @as(c.nk_size, @intCast(memory.len)),
    );
    return res;
}

pub fn free(e: *TextEdit) void {
    return c.nk_textedit_free(&e.c);
}

pub fn text(e: *TextEdit, t: []const u8) void {
    return c.nk_textedit_text(&e.c, nk.slice(t));
}

pub fn delete(e: *TextEdit, where: usize, len: usize) void {
    return c.nk_textedit_delete(&e.c, @as(c_int, @intCast(where)), @as(c_int, @intCast(len)));
}

pub fn deleteSelection(e: *TextEdit) void {
    return c.nk_textedit_delete_selection(&e.c);
}

pub fn selectAll(e: *TextEdit) void {
    return c.nk_textedit_select_all(&e.c);
}

pub fn cut(e: *TextEdit) bool {
    return c.nk_textedit_cut(&e.c) != 0;
}

pub fn paste(e: *TextEdit, t: []const u8) bool {
    return c.nk_textedit_paste(&e.c, nk.slice(t)) != 0;
}

pub fn undo(e: *TextEdit) void {
    return c.nk_textedit_undo(&e.c);
}

pub fn redo(e: *TextEdit) void {
    return c.nk_textedit_redo(&e.c);
}

test {
    std.testing.refAllDecls(@This());
}
