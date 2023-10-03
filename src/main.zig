const std = @import("std");

fn check_if_slice_is_palindrome(slice: []u8) bool {
    for (0..(slice.len + 1) / 2) |i| {
        if (slice[i] != slice[slice.len - i - 1]) {
            return false;
        }
    }
    return true;
}

fn get_mirrors(num: u64) error{ NoSpaceLeft, InvalidCharacter, Overflow }![2]u64 {
    var mirrored_buf = [_]u8{0} ** 60;
    const slice = try std.fmt.bufPrint(&mirrored_buf, "{d}", .{num});
    for (slice, 0..slice.len) |s, i| mirrored_buf[2 * slice.len - i - 1] = s;
    const first_num = try std.fmt.parseUnsigned(u64, mirrored_buf[0 .. slice.len * 2], 10);

    for (slice, 0..slice.len) |s, i| mirrored_buf[2 * slice.len - i - 2] = s;
    const second_num = try std.fmt.parseUnsigned(u64, mirrored_buf[0 .. slice.len * 2 - 1], 10);
    return [2]u64{ first_num, second_num };
}

fn check_if_binary_palindrome(num: u64) error{NoSpaceLeft}!bool {
    var binary_buf = [_]u8{0} ** 65;
    var binary_slice = try std.fmt.bufPrint(&binary_buf, "{b}", .{num});
    return check_if_slice_is_palindrome(binary_slice);
}

fn check_and_print(num: u64) error{NoSpaceLeft}!void {
    if (try check_if_binary_palindrome(num)) {
        std.debug.print("Found {d}\n", .{num});
    }
}

fn check_if_palindrome(num: u64) error{NoSpaceLeft}!bool {
    var buf = [_]u8{0} ** 30;
    var slice = try std.fmt.bufPrint(&buf, "{d}", .{num});
    return check_if_slice_is_palindrome(slice) and try check_if_binary_palindrome(num);
}

fn mirror(num: u64, expected_length: u32) error{ NoSpaceLeft, InvalidCharacter, Overflow }!u64 {
    var mirrored_buf = [_]u8{0} ** 60;
    const slice = try std.fmt.bufPrint(&mirrored_buf, "{d}", .{num});
    for (slice, 0..slice.len) |s, i| mirrored_buf[expected_length - i - 1] = s;
    return try std.fmt.parseUnsigned(u64, mirrored_buf[0..expected_length], 10);
}

fn find_palindrome(current_digits: u64, decimal_length: u32, recursion_depth: u32) error{ NoSpaceLeft, InvalidCharacter, Overflow }!void {
    // std.debug.print("find_palindrome {d} - {d} - {d}\n", .{ current_digits, decimal_length, recursion_depth });
    if (recursion_depth * 2 >= decimal_length) {
        try check_and_print(try mirror(current_digits, decimal_length));
        return;
    }

    var digit: u64 = 0;
    while (digit < 10) {
        if ((current_digits == 0) and (digit % 2 == 0)) {
            digit += 1;
            continue;
        }
        const new_digits = current_digits * 10 + digit;
        try find_palindrome(new_digits, decimal_length, recursion_depth + 1);
        digit += 1;
    }
}

pub fn main() !void {
    var i: u32 = 1;
    while (true) {
        // std.debug.print("start {d}\n", .{i});
        try find_palindrome(0, i, 0);
        i += 1;
    }
}

test "simple test should pass" {
    try std.testing.expect(try check_if_palindrome(1));
    try std.testing.expect(try check_if_palindrome(0));
    try std.testing.expect(try check_if_palindrome(3148955775598413));
    try std.testing.expect(!try check_if_palindrome(3148955775598414));
}
