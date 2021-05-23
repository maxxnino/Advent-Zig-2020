const std = @import("std");
const print = std.debug.print;
const ArrayList = std.ArrayList;
const test_allocator = std.testing.allocator;

pub fn main() !void {
    const path = "testdata/06.txt";
    const input = try std.fs.cwd().openFile(path, .{});
    var buf: [std.mem.page_size]u8 = undefined;
    var answers = [_]usize{0} ** ('z' - 'a' + 1);
    var counts: usize = 0;
    var people: usize = 0;
    while (try input.reader().readUntilDelimiterOrEof(&buf, '\n')) |line| {
        if (line.len == 0) {
            for (answers) |*c| {
                if (c.* == people) {
                    counts += 1;
                }
                c.* = 0;
            }
            people = 0;
            continue;
        }

        for (line) |c| {
            var index = c - 'a';
            answers[index] += 1;
        }
        people += 1;
    }

    for (answers) |c| {
        if (c == people) {
            counts += 1;
        }
    }
    print("{}", .{counts});
}
