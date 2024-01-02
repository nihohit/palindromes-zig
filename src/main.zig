const std = @import("std");
const math = std.math;

fn check_if_slice_is_palindrome(slice: []u8) bool {
    for (0..(slice.len + 1) / 2) |i| {
        if (slice[i] != slice[slice.len - i - 1]) {
            return false;
        }
    }
    return true;
}

fn get_mirrors(num: u256) error{ NoSpaceLeft, InvalidCharacter, Overflow }![2]u256 {
    var mirrored_buf = [_]u8{0} ** 256;
    const slice = try std.fmt.bufPrint(&mirrored_buf, "{d}", .{num});
    for (slice, 0..slice.len) |s, i| mirrored_buf[2 * slice.len - i - 1] = s;
    const first_num = try std.fmt.parseUnsigned(u256, mirrored_buf[0 .. slice.len * 2], 10);

    for (slice, 0..slice.len) |s, i| mirrored_buf[2 * slice.len - i - 2] = s;
    const second_num = try std.fmt.parseUnsigned(u256, mirrored_buf[0 .. slice.len * 2 - 1], 10);
    return [2]u256{ first_num, second_num };
}

fn check_if_binary_palindrome(num: u256) error{NoSpaceLeft}!bool {
    var binary_buf = [_]u8{0} ** 260;
    var binary_slice = try std.fmt.bufPrint(&binary_buf, "{b}", .{num});
    return check_if_slice_is_palindrome(binary_slice);
}

fn check_and_print(num: u256) error{NoSpaceLeft}!void {
    if (try check_if_binary_palindrome(num)) {
        const timestamp = std.time.timestamp();
        const time = fromTimestamp(timestamp);

        std.debug.print("Found {d} at {}\n", .{ num, time });
    }
}

fn check_if_palindrome(num: u256) error{NoSpaceLeft}!bool {
    var buf = [_]u8{0} ** 30;
    var slice = try std.fmt.bufPrint(&buf, "{d}", .{num});
    return check_if_slice_is_palindrome(slice) and try check_if_binary_palindrome(num);
}

fn mirror(num: u256, expected_length: u32) error{ NoSpaceLeft, InvalidCharacter, Overflow }!u256 {
    var mirrored_buf = [_]u8{0} ** 60;
    const slice = try std.fmt.bufPrint(&mirrored_buf, "{d}", .{num});
    for (slice, 0..slice.len) |s, i| mirrored_buf[expected_length - i - 1] = s;
    return try std.fmt.parseUnsigned(u256, mirrored_buf[0..expected_length], 10);
}

fn mirror_binary(num: u256, expected_length: u9) u256 {
    return num | @bitReverse(num) >> @truncate(u8, (256 - expected_length));
}

fn mirror_binary_max(num: u256, expected_length: u9, recursion_depth: u8) u256 {
    const reverse = @bitReverse(num);
    const truncated_recursion_depth = @truncate(u8, recursion_depth);
    const max_int: u256 = math.maxInt(u256);
    const only_ones = max_int >> truncated_recursion_depth;
    const reverse_and_ones = (only_ones | reverse) >> @truncate(u8, 256 - expected_length);
    const reverse_and_ones_with_space_for_num = (reverse_and_ones >> truncated_recursion_depth) << truncated_recursion_depth;
    return num | reverse_and_ones_with_space_for_num;
}

fn is_pruned(current_digits: u256, decimal_length: u32, recursion_depth: u8) error{ NoSpaceLeft, InvalidCharacter, Overflow }!bool {
    const changing_decimal_length = (decimal_length + 1 - 2 * recursion_depth) / 2;
    const exp = math.pow(u256, 10, changing_decimal_length);
    const min_decimal_palindrome_pre_mirror = current_digits * exp;
    const max_decimal_palindrome_pre_mirror = current_digits * exp + exp - 1;
    const min_decimal_palindrome = try mirror(min_decimal_palindrome_pre_mirror, decimal_length);
    const max_decimal_palindrome = try mirror(max_decimal_palindrome_pre_mirror, decimal_length);
    const bit_length = 256 - @clz(min_decimal_palindrome);
    const clz = @clz(max_decimal_palindrome);
    if ((256 - clz) != bit_length) {
        return false;
    }

    const one: u32 = 1;
    const binary_digits = min_decimal_palindrome % (one << @truncate(u5, recursion_depth));
    const min_binary_palindrome = mirror_binary(binary_digits, bit_length);
    const max_binary_palindrome = mirror_binary_max(binary_digits, bit_length, recursion_depth);

    return (min_binary_palindrome > max_decimal_palindrome) or (max_binary_palindrome < min_decimal_palindrome);
}

fn find_palindrome(current_digits: u256, decimal_length: u32, recursion_depth: u8) error{ NoSpaceLeft, InvalidCharacter, Overflow }!void {
    // std.debug.print("find_palindrome {d} - {d} - {d}\n", .{ current_digits, decimal_length, recursion_depth });
    if (recursion_depth * 2 >= decimal_length) {
        try check_and_print(try mirror(current_digits, decimal_length));
        return;
    }

    if ((current_digits > 0) and try is_pruned(current_digits, decimal_length, recursion_depth)) {
        return;
    }

    var digit: u256 = 0;
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

pub fn toRFC3339(dt: DateTime) [20]u8 {
    var buf: [20]u8 = undefined;
    _ = std.fmt.formatIntBuf(buf[0..4], dt.year, 10, .lower, .{ .width = 4, .fill = '0' });
    buf[4] = '-';
    paddingTwoDigits(buf[5..7], dt.month);
    buf[7] = '-';
    paddingTwoDigits(buf[8..10], dt.day);
    buf[10] = 'T';

    paddingTwoDigits(buf[11..13], dt.hour);
    buf[13] = ':';
    paddingTwoDigits(buf[14..16], dt.minute);
    buf[16] = ':';
    paddingTwoDigits(buf[17..19], dt.second);
    buf[19] = 'Z';

    return buf;
}

fn paddingTwoDigits(buf: *[2]u8, value: u8) void {
    switch (value) {
        0 => buf.* = "00".*,
        1 => buf.* = "01".*,
        2 => buf.* = "02".*,
        3 => buf.* = "03".*,
        4 => buf.* = "04".*,
        5 => buf.* = "05".*,
        6 => buf.* = "06".*,
        7 => buf.* = "07".*,
        8 => buf.* = "08".*,
        9 => buf.* = "09".*,
        // todo: optionally can do all the way to 59 if you want
        else => _ = std.fmt.formatIntBuf(buf, value, 10, .lower, .{}),
    }
}

pub const DateTime = struct {
    year: i64,
    month: i64,
    day: i64,
    hour: i64,
    minute: i64,
    second: i64,
};

pub fn fromTimestamp(ts: i64) DateTime {
    const SECONDS_PER_DAY = 86400;
    const DAYS_PER_YEAR = 365;
    const DAYS_IN_4YEARS = 1461;
    const DAYS_IN_100YEARS = 36524;
    const DAYS_IN_400YEARS = 146097;
    const DAYS_BEFORE_EPOCH = 719468;

    const seconds_since_midnight: i64 = @rem(ts, SECONDS_PER_DAY);
    var day_n: i64 = DAYS_BEFORE_EPOCH + @divTrunc(ts, SECONDS_PER_DAY);
    var temp: i64 = 0;

    temp = 4 * @divTrunc(day_n + DAYS_IN_100YEARS + 1, DAYS_IN_400YEARS) - 1;
    const this = (100 * temp);
    var year = this;
    day_n -= DAYS_IN_100YEARS * temp + @divTrunc(temp, 4);

    temp = 4 * @divTrunc((day_n + DAYS_PER_YEAR + 1), DAYS_IN_4YEARS) - 1;
    year += temp;
    day_n -= DAYS_PER_YEAR * temp + @divTrunc(temp, 4);

    var month = @divTrunc((5 * day_n + 2), 153);
    const day = day_n - @divTrunc((@as(i64, month) * 153 + 2), 5) + 1;

    month += 3;
    if (month > 12) {
        month -= 12;
        year += 1;
    }

    return DateTime{ .year = year, .month = month, .day = day, .hour = @divTrunc(seconds_since_midnight, 3600), .minute = @divTrunc(@mod(seconds_since_midnight, 3600), 60), .second = @mod(seconds_since_midnight, 60) };
}
