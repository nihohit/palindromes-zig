const std = @import("std");

fn check_if_slice_is_palindrome(slice: []u8) bool {
    for (0..(slice.len + 1) / 2) |i| {
        if (slice[i] != slice[slice.len - i-1]) {
            return false;
        }
    }
    return true;
}

fn get_mirrors(num: u64) error{NoSpaceLeft,InvalidCharacter,Overflow}![2]u64 {
    var mirrored_buf = [_]u8{0} ** 60;
    const slice = try std.fmt.bufPrint(&mirrored_buf, "{d}", .{num});
    for (slice, 0..slice.len) |s, i| mirrored_buf[2 * slice.len - i - 1] = s;
    const first_num = try std.fmt.parseUnsigned(u64, mirrored_buf[0..slice.len * 2], 10);

    for (slice, 0..slice.len-1) |s, i| mirrored_buf[2 * slice.len - i - 2] = s;
    const second_num = try std.fmt.parseUnsigned(u64, mirrored_buf[0..slice.len * 2-1], 10);
    return [2]u64 {first_num, second_num};
}

fn check_if_binary_palindrome(num: u64)error{NoSpaceLeft}!bool {
    var binary_buf =  [_]u8{0} ** 65;
    var binary_slice = try std.fmt.bufPrint(&binary_buf, "{b}", .{num});
    return  check_if_slice_is_palindrome(binary_slice);
}

fn check_if_palindrome(num: u64) error{NoSpaceLeft}!bool {
    var buf = [_]u8{0} ** 30;
    var slice = try std.fmt.bufPrint(&buf, "{d}", .{num});
    return check_if_slice_is_palindrome(slice) and try check_if_binary_palindrome(num);
}

pub fn main() !void {
    var i:u64 = 0;
    while (true) {
        // std.debug.print("checking {d}.\n", .{i});
        const arr = try get_mirrors(i);
        if (try check_if_binary_palindrome(arr[0])) {
            std.debug.print("Found {d}\n", .{arr[0]});
        }
        if (try check_if_binary_palindrome(arr[1])) {
            std.debug.print("Found {d}\n", .{arr[1]});
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

