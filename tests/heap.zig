const std = @import("std");
const swift_lib = @import("swift_lib");

test "PageAllocator" {
    var pages = try swift_lib.heap.PageAllocator.init(84);
    defer pages.deinit();

    try std.testing.expect(pages.mem.len == swift_lib.os.page_size * 84);
}

test "ArenaAllocator" {
    var pages = try swift_lib.heap.PageAllocator.init(84);
    defer pages.deinit();
    var arena = swift_lib.heap.ArenaAllocator.init(pages.mem);
    const allocator = arena.allocator();

    _ = try allocator.alloc(u128, 64);
    _ = try allocator.alloc(u64, 54);

    try std.testing.expect(arena.pos ==
        (swift_lib.math.alignForward(usize, @sizeOf(u128) * 64, 8) +
        swift_lib.math.alignForward(usize, @sizeOf(u64) * 54, 8)));
}

test "FrelistAllocator" {
    var pages = try swift_lib.heap.PageAllocator.init(1);
    defer pages.deinit();
    var freelist = swift_lib.heap.FreelistAllocator.init(pages.mem);
    var allocator = freelist.allocator();

    try std.testing.expect(freelist.freelist == null);

    const allocated1 = try allocator.alloc(u8, 64);
    const allocated2 = try allocator.alloc(u128, 64);
    allocator.free(allocated1);
    allocator.free(allocated2);

    try std.testing.expect(freelist.freelist != null);
    try std.testing.expect(freelist.freelist.?.next != null);
    try std.testing.expect(freelist.freelist.?.len == @sizeOf(u128) * 64);
    try std.testing.expect(freelist.freelist.?.next.?.len == @sizeOf(u8) * 64);
}

test "ArrayList" {
    var pages = try swift_lib.heap.PageAllocator.init(5);
    defer pages.deinit();
    var arena = swift_lib.heap.ArenaAllocator.init(pages.mem);
    const allocator = arena.allocator();
    var arraylist = try swift_lib.heap.ArrayList(usize).init(allocator);

    inline for (0..30) |idx| {
        try std.testing.expect(arraylist.pos == idx);
        try arraylist.push(idx);
    }

    inline for (0..30) |idx| {
        try std.testing.expect(arraylist.get(idx).? == idx);
    }
}
