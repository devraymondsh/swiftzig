const math = @import("../math.zig");
const Allocator = @import("Allocator.zig");

const FreeListNode = packed struct {
    len: usize,
    next: ?*FreeListNode,
};

mem: []u8,
pos: usize = 0,
freelist: ?*FreeListNode = null,

/// A simple freelist allocator implementation.
const FreelistAllocator = @This();

pub fn unlikely() void {
    @setCold(true);
}

/// Initializes a freelist allocator from a memory slice.
pub fn init(mem: []u8) FreelistAllocator {
    return FreelistAllocator{ .mem = mem, .pos = 0, .freelist = null };
}

pub fn alloc(ctx: *anyopaque, _len: usize) ?[*]align(8) u8 {
    const self: *FreelistAllocator = @alignCast(@ptrCast(ctx));
    const len = if (_len > 16) _len else 16;
    if (self.freelist) |freelist| {
        if (freelist.len >= len) {
            var freelist_slice: []u8 = undefined;
            freelist_slice.len = freelist.len;
            freelist_slice.ptr = @alignCast(@ptrCast(freelist));

            if (freelist.len - len != 0) {
                @memset(freelist_slice[len..freelist.len], 0);
            }

            self.freelist = freelist.next;

            return @alignCast(@ptrCast(freelist_slice[0..len].ptr));
        }
    }

    const new_pos = self.pos + len;
    if (new_pos > self.mem.len) {
        unlikely();
        return null;
    }

    const ret: [*]align(8) u8 = @alignCast(@ptrCast(&self.mem[self.pos]));
    self.pos = new_pos;

    return ret;
}

fn free(ctx: *anyopaque, buf: [*]align(8) u8, len: usize) void {
    const self: *FreelistAllocator = @alignCast(@ptrCast(ctx));
    const freelist = @as(*FreeListNode, @alignCast(@ptrCast(buf)));

    if (len > 16) {
        freelist.*.len = @intCast(math.alignForward(usize, len, 8));
    } else {
        freelist.*.len = 16;
    }

    freelist.*.next = self.freelist;
    self.freelist = freelist;
}
fn resize(ctx: *anyopaque, buf: [*]align(8) u8, len: usize, new_len: usize) bool {
    const self: *FreelistAllocator = @alignCast(@ptrCast(ctx));
    if (@intFromPtr(self.mem[self.pos..].ptr) == (@intFromPtr(buf) + len)) {
        const new_pos = self.pos + (new_len - len);

        if (new_pos <= self.mem.len) {
            self.pos = new_pos;
            return true;
        } else {
            unlikely();
        }
    }

    return false;
}

/// Returns an allocator interface.
pub fn allocator(self: *FreelistAllocator) Allocator {
    @setCold(true);
    return Allocator{ .ptr = self, .vtable = &.{
        .alloc = alloc,
        .resize = resize,
        .free = free,
    } };
}
