// For types: want C ABI, don't want "pub"...
const struct_jv_refcnt = opaque {};
const union_unnamed_7 = extern union {
    ptr: ?*struct_jv_refcnt,
    number: f64,
};
const jv = extern struct {
    kind_flags: u8,
    pad_: u8,
    offset: c_ushort,
    size: c_int,
    u: union_unnamed_7,
};

const struct_jq_state = opaque {};
const jq_state = struct_jq_state;
const JV_KIND_STRING: c_int = 5;
const jv_kind = c_uint;

extern fn jv_get_kind(jv) jv_kind;
extern fn jv_invalid_with_msg(jv) jv;
extern fn jv_string([*c]const u8) jv;
extern fn jv_string_length_bytes(jv) c_int;
extern fn jv_string_sized([*c]const u8, c_int) jv;
extern fn jv_string_value(jv) [*c]const u8;

const std = @import("std");
const Md5 = std.crypto.hash.Md5;
const bufPrint = std.fmt.bufPrint;
// zig<=0.13 //const RndGen = std.rand.DefaultPrng;
const RndGen = std.Random.DefaultPrng; // zig==0.14(dev)

// All the above, and most of the function f_md5 was made using 'zig translate-c' on builtin.c
// (You have to grab 'builtin.inc' from a build of the original jq).
//
// What was needed from 'builtin.zig' (not included) was added in here to enable zig-native compile.
// All that was needed in f_md5 was to figure out the call to Md5.hash(...)
pub export fn f_md5(_: ?*jq_state, arg_a: jv) callconv(.C) jv {
    if (jv_get_kind(arg_a) != JV_KIND_STRING) return jv_invalid_with_msg(jv_string("md5() requires string input"));
    const alen: c_int = jv_string_length_bytes(arg_a);
    var buf: [16]u8 = undefined;
    Md5.hash(jv_string_value(arg_a)[0..@intCast(alen)], &buf, .{});
    var b: [32]u8 = undefined; // [32:0] doesn't seem to be needed for jv_string_sized(...)
    _ = bufPrint(&b, "{}", .{std.fmt.fmtSliceHexLower(&buf)}) catch unreachable;
    const ret: jv = jv_string_sized(&b, 32);
    return ret;
}

extern fn jv_free(jv) void;
extern fn jv_number(f64) jv;

// As above, based on f_now:
pub export fn f_rand(_: ?*jq_state, arg_a: jv) callconv(.C) jv {
    const a = arg_a;
    jv_free(a);
    var rnd = RndGen.init(@intCast(std.time.nanoTimestamp()));
    return jv_number(rnd.random().float(f64));
}
