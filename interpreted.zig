const std = @import("std");

const NLOOPS: usize = 10_000_000;

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();

    var args = std.process.args();
    _ = args.skip();
    const prg = args.next() orelse {
        std.debug.print("Usage: jitcalc \"PROGRAM\"\n", .{});
        std.process.exit(1);
    };

    var result: isize = 1;
    for (0..NLOOPS) |_| {
        result = 1;
        for (prg) |token| {
            if (token == ' ') {
                continue;
            }

            switch (token) {
                '+' => result += 1,
                '-' => result -= 1,
                '*' => result *= 2,
                '/' => result = @divTrunc(result, 2),
                else => return,
            }
        }
    }

    try stdout.print("{} N={}\n", .{ result, NLOOPS });
}
