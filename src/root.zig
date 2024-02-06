pub const heap = struct {
    pub const Allocator = @import("heap/Allocator.zig");
    pub const ArenaAllocator = @import("heap/ArenaAllocator.zig");
    pub const ArrayList = @import("heap/ArrayList.zig").ArrayList;
    pub const PageAllocator = @import("heap/PageAllocator.zig");
    pub const FreelistAllocator = @import("heap/FreelistAllocator.zig");
};

pub const os = struct {
    pub usingnamespace @import("os/os.zig");
};

pub const start = @import("os/start.zig");
pub const math = @import("math.zig");
pub const mem = @import("mem.zig");
