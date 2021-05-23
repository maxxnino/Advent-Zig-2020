const std = @import("std");
const print = std.debug.print;
const ArrayList = std.ArrayList;
const test_allocator = std.testing.allocator;

const Passport = struct {
    byr: bool = false,
    iyr: bool = false,
    eyr: bool = false,
    hgt: bool = false,
    hcl: bool = false,
    ecl: bool = false,
    pid: bool = false,
    cid: bool = false,

    pub fn testprint() void {
        inline for (@typeInfo(Passport).Struct.fields) |structField| {
            print("{s}\n", .{structField});
        }
    }
    pub fn addValue(self: *Passport, fieldName: []const u8, value: []const u8) void {
        inline for (@typeInfo(Passport).Struct.fields) |structField| {
            if (std.mem.eql(u8, structField.name, fieldName)) {
                @field(self, structField.name) = true;
                return;
            }
        }
    }
    pub fn testValue(self: *Passport, fieldName: []const u8, value: []const u8) bool {
        if (std.mem.eql(u8, "byr", fieldName)) {
            const valueInt = std.fmt.parseInt(usize, value, 10) catch |err| std.debug.panic("{s} \n", .{value});
            if (1920 > valueInt or valueInt > 2002) {
                return false;
            }
            return true;
        }

        if (std.mem.eql(u8, "iyr", fieldName)) {
            const valueInt = std.fmt.parseInt(usize, value, 10) catch |err| std.debug.panic("{s} \n", .{value});
            if (2010 > valueInt or valueInt > 2020) {
                return false;
            }
            return true;
        }
        if (std.mem.eql(u8, "eyr", fieldName)) {
            const valueInt = std.fmt.parseInt(usize, value, 10) catch |err| std.debug.panic("{s} \n", .{value});
            if (2020 > valueInt or valueInt > 2030) {
                return false;
            }
            return true;
        }
        if (std.mem.eql(u8, "hgt", fieldName)) {
            if (value.len == 4 or value.len == 5) {} else {
                return false;
            }
            const segmentIndex = value.len - 2;

            const valueInt = std.fmt.parseInt(usize, value[0..segmentIndex], 10) catch |err| std.debug.panic("{s} \n", .{value});
            if (std.mem.eql(u8, value[segmentIndex..], "cm")) {
                if (150 <= valueInt and valueInt <= 193) {
                    return true;
                }
            } else if (std.mem.eql(u8, value[segmentIndex..], "in")) {
                if (59 <= valueInt and valueInt <= 76) {
                    return true;
                }
            }
            return false;
        }
        if (std.mem.eql(u8, "hcl", fieldName)) {
            if (value[0] != '#') {
                print("{s} - {s}\n", .{ fieldName, value });
                return false;
            }
            for (value[1..]) |c| {
                if (c < '0' or (c > '9' and c < 'a') or c > 'f') {
                    print("{s} - {s}\n", .{ fieldName, value });
                    return false;
                }
            }

            return true;
        }
        if (std.mem.eql(u8, "ecl", fieldName)) {
            if (std.mem.eql(u8, "amb", value)) {
                return true;
            }
            if (std.mem.eql(u8, "blu", value)) {
                return true;
            }
            if (std.mem.eql(u8, "brn", value)) {
                return true;
            }
            if (std.mem.eql(u8, "gry", value)) {
                return true;
            }
            if (std.mem.eql(u8, "grn", value)) {
                return true;
            }
            if (std.mem.eql(u8, "hzl", value)) {
                return true;
            }
            if (std.mem.eql(u8, "oth", value)) {
                return true;
            }
            print("{s} - {s}\n", .{ fieldName, value });
            return false;
        }
        if (std.mem.eql(u8, "pid", fieldName)) {
            if (value.len != 9) {
                print("{s} - {s}\n", .{ fieldName, value });
                return false;
            }
            for (value) |c| {
                if (c < '0' and c > '9') {
                    print("{s} - {s}\n", .{ fieldName, value });
                    return false;
                }
            }
            return true;
        }
        return true;
    }
    pub fn reset(self: *Passport) void {
        inline for (@typeInfo(Passport).Struct.fields) |structField| {
            @field(self, structField.name) = false;
        }
    }
    pub fn isValid(self: *Passport) bool {
        return self.byr and
            self.iyr and
            self.eyr and
            self.hgt and
            self.hcl and
            self.ecl and
            self.pid;
    }
};
pub fn main() !void {
    //var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    //defer arena.deinit();
    const path = "testdata/04.txt";
    const input = try std.fs.cwd().openFile(path, .{});
    var buf: [std.mem.page_size]u8 = undefined;
    var testingPassport = Passport{};
    var valid: usize = 0;
    var waitNewLine = false;
    while (try input.reader().readUntilDelimiterOrEof(&buf, '\n')) |line| {
        if (line.len == 0) {
            waitNewLine = false;
            if (testingPassport.isValid()) {
                valid += 1;
            }
            testingPassport.reset();
            continue;
        } else if (waitNewLine) {
            continue;
        }
        var it = std.mem.tokenize(line, ": ");
        while (it.next()) |fieldName| {
            var value = it.next().?;
            if (testingPassport.testValue(fieldName, value)) {
                testingPassport.addValue(fieldName, value);
            } else {
                waitNewLine = true;
                break;
            }
        }
    }
    if (testingPassport.isValid()) {
        valid += 1;
    }
    print("Valid: {}\n", .{valid});
}
