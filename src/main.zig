const std = @import("std");

fn check_if_slice_is_palindrome(slice: []u8) bool {
    for (0..(slice.len + 1) / 2) |i| {
        if (slice[i] != slice[slice.len - i-1]) {
            return false;
        }
    }
    return true;
}

fn check_if_palindrome(num: u64) error{NoSpaceLeft}!bool {
    var buf = [_]u8{0} ** 30;
    var binary_buf =  [_]u8{0} ** 65;
    var slice = try std.fmt.bufPrint(&buf, "{d}", .{num});
    var binary_slice = try std.fmt.bufPrint(&binary_buf, "{b}", .{num});
    return check_if_slice_is_palindrome(slice) and check_if_slice_is_palindrome(binary_slice);
}

pub fn main() !void {
    // Prints to stderr (it's a shortcut based on `std.io.getStdErr()`)
    std.debug.print("All your {s} are belong to us.\n", .{"codebase"});

    var i:u64 = 0;
    while (true) {
        const res = try check_if_palindrome(i);
        if (res) {
            std.debug.print("Found {d}.\n", .{i});
        }
        i += 1;
    }
}

test "simple test should pass" {
    try std.testing.expect( try check_if_palindrome(1));
    try std.testing.expect(try check_if_palindrome(0));
    try std.testing.expect(try check_if_palindrome(3148955775598413));
    try std.testing.expect(!try check_if_palindrome(3148955775598414));
}
