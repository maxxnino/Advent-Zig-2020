const std = @import("std");
const print = std.debug.print;
const ArrayList = std.ArrayList;
const test_allocator = std.testing.allocator;

pub fn main() !void {
    const path = "testdata/05.txt";
    const input = try std.fs.cwd().openFile(path, .{});
    var buf: [std.mem.page_size]u8 = undefined;
    var seets = [_]bool{false} ** 849;
    var max: usize = 0;
    while (try input.reader().readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var rowMin: usize = 0;
        var rowMid: usize = 0;
        var rowMax: usize = 127;
        var columnMin: usize = 0;
        var columnMid: usize = 0;
        var columnMax: usize = 7;
        for (line) |c| {
            switch (c) {
                'F' => {
                    rowMid = (rowMin + rowMax) / 2;
                    rowMax = rowMid;
                },
                'B' => {
                    rowMid = 1 + (rowMin + rowMax) / 2;
                    rowMin = rowMid;
                },
                'L' => {
                    columnMid = (columnMin + columnMax) / 2;
                    columnMax = columnMid;
                },
                'R' => {
                    columnMid = 1 + (columnMin + columnMax) / 2;
                    columnMin = columnMid;
                },
                else => unreachable,
            }
        }
        const currentSeatID = rowMid * 8 + columnMid;
        if (currentSeatID > max) {
            max = currentSeatID;
        }
        seets[currentSeatID] = true;
    }
    var prev = true;
    var prevprev = true;
    for (seets) |current, index|{
       if(current and !prev and prevprev) {
            print("{}\n", .{index - 1});
            break;
        }
        prevprev = prev;
        prev = current;
        
    }
    print("{}", .{max});
}
