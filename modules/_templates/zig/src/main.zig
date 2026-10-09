const std = @import("std");

pub fn main() !void {
    std.debug.print("Hello, world!\n", .{});
}

test "basic" {
    try std.testing.expectEqual(@as(i32, 42), 40 + 2);
}
