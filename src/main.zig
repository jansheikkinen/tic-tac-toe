// main.zig

const std = @import("std");

const Piece = enum(u1) {
  X, O
};


const Board = struct {
  board: [9]?Piece = [_]?Piece { null } ** 9,

  pub fn init() Board {
    return Board { };
  }

  fn checkPlayerWon(self: *const Board) ?Piece {
    var i: usize = 0;
    while (i < 3) : (i += 1) {
      if (self.board[i] == self.board[i + 3]
        and self.board[i] == self.board[i + 6])
        return self.board[i];

      if (self.board[i * 3] == self.board[i * 3 + 1]
        and self.board[i * 3] == self.board[i * 3 + 2])
        return self.board[i * 3];
    }

    if (self.board[0] == self.board[4] and self.board[0] == self.board[8])
      return self.board[0];

    if (self.board[2] == self.board[4] and self.board[2] == self.board[6])
      return self.board[2];

    return null;
  }

  fn endGame(self: *const Board, player: Piece) noreturn {
    self.printBoard();
    switch (player) {
      .X => std.debug.print("{c} wins!\n", .{ 'x' }),
      .O => std.debug.print("{c} wins!\n", .{ 'o' })
    }
    std.process.exit(0);
  }

  fn querySlot(self: *const Board) usize {
    const stdin = std.io.getStdIn().reader();

    std.debug.print("where to place piece: ", .{});

    var buffer: [32]u8 = [_]u8 { 0 } ** 32;
    var line = stdin.readUntilDelimiterOrEof(&buffer, '\n') catch |err| {
      std.debug.print("failed to get input: {any}\n", .{ @errorName(err) });
      return self.querySlot();
    } orelse {
      std.debug.print("failed to get input\n", .{});
      return self.querySlot();
    };

    const delimiterIndex = std.mem.indexOf(u8, line, " ") orelse {
      std.debug.print("please write two space-separated numbers\n", .{});
      return self.querySlot();
    };

    const x = std.fmt.parseInt(i8, line[0..delimiterIndex], 0) catch |err| {
      std.debug.print("failed to parse x: {s}\n", .{ @errorName(err) });
      return self.querySlot();
    };

    const y = std.fmt.parseInt(i8, line[delimiterIndex + 1..line.len], 0) catch |err| {
      std.debug.print("failed to parse y: {s}\n", .{ @errorName(err) });
      return self.querySlot();
    };


    const xi = @bitCast(u8, x) - 1;
    const yi = @bitCast(u8, y) - 1;
    if (xi < 0 or xi > 2) {
      std.debug.print("invalid x coordinate: {d}\n", .{ xi + 1 });
      return self.querySlot();
    } else if (yi < 0 or yi > 2) {
      std.debug.print("invalid y coordinate: {d}\n", .{ yi + 1 });
      return self.querySlot();
    } else if (self.board[yi * 3 + xi] != null) {
      std.debug.print("this spot is already taken\n", .{});
      return self.querySlot();
    } else return yi * 3 + xi;
  }

  fn printBoard(self: *const Board) void {
    std.debug.print("+---+---+---+\n| ", .{});

    var index: usize = 0;
    while (index < self.board.len) : (index += 1) {
      if (index % 3 == 0 and index != 0)
        std.debug.print("\n+---+---+---+\n| ", .{});

      if (self.board[index]) |piece| {
        switch (piece) {
          .X => std.debug.print("{c} ", .{ 'x' }),
          .O => std.debug.print("{c} ", .{ 'o' })
        }
      } else {
        std.debug.print("  ", .{});
      }
      std.debug.print("| ", .{});
    }

    std.debug.print("\n+---+---+---+\n", .{});
  }

  fn executeTurn(self: *Board, player: Piece) void {
    const playerWon = self.checkPlayerWon();
    if (playerWon) |won| {
      self.endGame(won);
    } else {
      self.printBoard();
      self.board[self.querySlot()] = player;
      self.executeTurn(@intToEnum(Piece, @enumToInt(player) +% 1));
    }
  }

  pub fn start(self: *Board) void {
    self.executeTurn(Piece.X);
  }
};


pub fn main() !void {
  var game = Board.init();
  game.start();
}
