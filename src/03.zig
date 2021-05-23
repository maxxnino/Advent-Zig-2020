const std = @import("std");
const print = std.debug.print;
const ArrayList = std.ArrayList;
const test_allocator = std.testing.allocator;
pub fn main() !void {
    //var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    //defer arena.deinit();
    const path = "testdata/03.txt";
    const input = try std.fs.cwd().openFile(path, .{});
    var buf: [std.mem.page_size]u8 = undefined;
    var list = ArrayList(u8).init(test_allocator);
    defer list.deinit();
    var width: usize = 0;
    var height: usize = 0;
    while (try input.reader().readUntilDelimiterOrEof(&buf, '\n')) |line| {
        if (width == 0) {
            width = line.len;
        } else if (width != line.len) {
            std.debug.panic("Old width {} - new width {}", .{ width, line.len });
        }
        height += 1;

        try list.appendSlice(line);
    }
    print("Width: {} - Height: {}\n", .{ width, height });
    const sloop = [_][2]usize{
        [_]usize{ 1, 1 },
        [_]usize{ 3, 1 },
        [_]usize{ 5, 1 },
        [_]usize{ 7, 1 },
        [_]usize{ 1, 2 },
    };
    var res: usize = 1;
    for (sloop) |s| {
        var h: usize = s[1];
        var w: usize = 0;
        var tree: usize = 0;
        while (h < height) : (h += s[1]) {
            w = @rem(w + s[0], width);
            if (list.items[w + width * h] == '#') {
                tree += 1;
            }
        }
        if (tree == 0) {
            print("tree = 0", .{});
        }
        res *= tree;
    }
    print("tree {}", .{res});
}
