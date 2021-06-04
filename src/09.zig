const std = @import("std");
const print = std.debug.print;
const ArrayList = std.ArrayList;
const test_allocator = std.testing.allocator;

pub fn part1And2() !void {
    const path = "testdata/09.txt";
    const input = try std.fs.cwd().openFile(path, .{});
    var buf: [std.mem.page_size]u8 = undefined;
    const max_size = 25;
    var number_array = ArrayList(usize).init(test_allocator);
    while (try input.reader().readUntilDelimiterOrEof(&buf, '\n')) |line| {
        const number = try std.fmt.parseUnsigned(usize, line, 10);
        try number_array.append(number);
    }
    var items = number_array.items;
    var found_number: usize = 0;
    var found_index: usize = 0;
    for (items[max_size..]) |n, i| {
        var x: usize = i;
        const end = i + max_size;
        var isFound: bool = false;
        outer: while (x < end) : (x += 1) {
            var y: usize = x;
            while (y < end) : (y += 1) {
                if (items[x] + items[y] == n) {
                    isFound = true;
                    break :outer;
                }
            }
        }
        if (!isFound) {
            found_number = n;
            found_index = i;
            break;
        }
    }
    var begin: usize = 0;
    var end: usize = 0;
    var curent_acc: usize = 0;
    for (items[0..found_index]) |value, i| {
        var next_acc: usize = curent_acc + value;
        if (next_acc == found_number) {
            end = i;
            break;
        }
        if (next_acc > found_number) {
            while (next_acc > found_number) {
                next_acc -= items[begin];
                begin += 1;
            }
            if (next_acc == found_number) {
                end = i;
                break;
            }
            curent_acc = next_acc;
            continue;
        }
        if (next_acc < found_number) {
            curent_acc = next_acc;
        }
    }
    var weakest_number: usize = 0;
    var smallest: usize = std.math.maxInt(usize);
    var largest: usize = 0;
    for (items[begin..end]) |value| {
        smallest = std.math.min(smallest, value);
        largest = std.math.max(largest, value);
    }
    weakest_number = smallest + largest;
    print("found_number: {} - weakest_number {}", .{ found_number, weakest_number });
}
pub fn main() !void {
    try part1And2And2();
}
