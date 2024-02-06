const builtin = @import("builtin");
const os = @import("../os/os.zig");
const Allocator = @import("Allocator.zig");
const math = @import("../math.zig");

const PageAllocatorInitError = error{
    FailedToInitialize,
};

mem: []align(os.page_size) u8,

/// A simple page allocator.
const PageAllocator = @This();

/// Allocates n pages.
pub fn init(n: usize) PageAllocatorInitError!PageAllocator {
    @setRuntimeSafety(false);
    const len = n * os.page_size;
    if (builtin.os.tag == .linux) {
        const mmapsys_res = os.linux.syscall(.mmap, .{
            @as(usize, 0),
            len,
            os.linux.PROT.READ | os.linux.PROT.WRITE,
            os.linux.MAP.ANONYMOUS | os.linux.MAP.PRIVATE,
            0,
            @as(u64, 0),
        });

        if (os.linux.get_errno(mmapsys_res) == .SUCCESS) {
            return PageAllocator{
                .mem = @as(
                    [*]align(os.page_size) u8,
                    @ptrFromInt(mmapsys_res),
                )[0..len],
            };
        }

        return PageAllocatorInitError.FailedToInitialize;
    } else @compileError("Unsupported OS/CPU!");
}

/// Deallocates all the pages.
pub fn deinit(self: *PageAllocator) void {
    @setRuntimeSafety(false);
    if (builtin.os.tag == .linux) {
        _ = os.linux.syscall(.munmap, .{ self.mem.ptr, self.mem.len });
    }
}
