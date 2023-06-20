class GameService
  @@board = [""] * 9
  @@player1 = {}
  @@player2 = {}
  @@player_count = 0
  @@turn = 1

  WINNING_COMBINATIONS = [
    [0, 1, 2], [3, 4, 5], [6, 7, 8], # Rows
    [0, 3, 6], [1, 4, 7], [2, 5, 8], # Columns
    [0, 4, 8], [2, 4, 6],            # Diagonals
  ]

  class << self
    attr_accessor :board, :player1, :player2, :player_count
  end

  def initialize(game_channel)
    @game_channel = game_channel
  end

  def join_game(name, connection_id)
    player_count = GameService.player_count
    if player_count < 0
      player_count = 0
    end
    a = GameService.player1

    if player_count < 2
      GameService.send("player#{player_count + 1}_update", { "name" => name, "connection_id" => connection_id })
      GameService.player_count_update(player_count + 1)
      true
    else
      false
    end
  end

  def leave_game(connection_id)
    GameService.player_count_update(GameService.player_count - 1)

    player1 = GameService.player1
    player2 = GameService.player2
    if player1["connection_id"] == connection_id
      GameService.player1_update(player2)
    end
    GameService.player2_update({})

    GameService.reset_game
    ActionCable.server.broadcast "game_channel", get_params
  end

  def get_params
    {
      type: "update_game",
      player1: GameService.player1,
      player2: GameService.player2,
      player_count: GameService.player_count,
      board: GameService.board,
    }
  end

  def put_sign(payload, connection_id)
    data = payload["payload"]
    index = data["index"].to_i

    player1 = GameService.player1
    player2 = GameService.player2
    board = GameService.board

    if board[index] != ""
      return
    end

    if player1["connection_id"] == connection_id && GameService.turn == 1
      GameService.board_update(index, 1)
      GameService.turn_update(2)
    elsif player2["connection_id"] == connection_id && GameService.turn == 2
      GameService.board_update(index, 2)
      GameService.turn_update(1)
    else
      return
    end

    ActionCable.server.broadcast "game_channel", get_params
    check_game_status
  end

  def check_game_status
    if check_sign_is_winner?(1)
      ActionCable.server.broadcast "game_channel", { type: "player_won", player: "player1" }
    elsif check_sign_is_winner?(2)
      ActionCable.server.broadcast "game_channel", { type: "player_won", player: "player2" }
    end
  end

  def check_sign_is_winner?(sign)
    player_indexes = find_indexes_of_elements(sign)

    if player_indexes.empty?
      false
    else
      player_indexes_str = player_indexes.map(&:to_s)

      WINNING_COMBINATIONS.any? do |combination|
        combination.all? { |index| player_indexes_str.include?(index.to_s) }
      end
    end
  end

  def find_indexes_of_elements(search_value)
    board = GameService.board
    indexes = []

    board.each_with_index do |element, index|
      indexes << index if element == search_value
    end

    indexes
  end

  def self.reset_game
    @@board = [""] * 9
    @@turn = 1
  end

  def self.board
    @@board
  end

  def self.board_update(index, value)
    @@board[index] = value
  end

  def self.player1
    @@player1
  end

  def self.player1_update(user)
    @@player1 = user
  end

  def self.player2
    @@player2
  end

  def self.player2_update(user)
    @@player2 = user
  end

  def self.player_count
    @@player_count
  end

  def self.player_count_update(value)
    @@player_count = value
  end

  def self.turn
    @@turn
  end

  def self.turn_update(value)
    @@turn = value
  end
end
