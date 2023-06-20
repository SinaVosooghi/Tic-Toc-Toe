require "test_helper"

class GameServiceTest < ActiveSupport::TestCase
  setup do
    @game_service = GameService.new(nil)
  end

  test "join_game should add a player if there is space available" do
    GameService.player_count_update(1)
    joined = @game_service.join_game("Player 1", 1)

    assert_equal 2, GameService.player_count
    assert_equal true, joined
  end

  test "join_game should not add a player if there is no space available" do
    GameService.player_count_update(2)

    player_count = GameService.player_count
    joined = @game_service.join_game("Player 3", 3)

    assert_equal player_count, GameService.player_count
    assert_equal false, joined
  end

  test "leave_game should remove a player and reset the game state" do
    GameService.player_count_update(2)
    GameService.board_update(0, 1)
    GameService.player1_update({ "name" => "Player 1", "connection_id" => 1 })
    GameService.player2_update({ "name" => "Player 2", "connection_id" => 2 })

    @game_service.leave_game(1)

    assert_equal 1, GameService.player_count
    assert_equal({ "name" => "Player 2", "connection_id" => 2 }, GameService.player1)
    assert_equal({}, GameService.player2)
    assert_equal [""] * 9, GameService.board
  end

  test "put_sign should update the board and change the turn if the move is valid" do
    GameService.player1_update({ "name" => "Player 1", "connection_id" => 1 })
    GameService.player2_update({ "name" => "Player 2", "connection_id" => 2 })

    @game_service.put_sign({ "payload" => { "index" => 0 } }, 1)

    assert_equal 2, GameService.turn
    assert_equal 1, GameService.board[0]
  end

  test "put_sign should not update the board and turn if the move is invalid" do
    GameService.player1_update({ "name" => "Player 1", "connection_id" => 1 })
    GameService.player2_update({ "name" => "Player 2", "connection_id" => 2 })
    GameService.board_update(0, 1)

    @game_service.put_sign({ "payload" => { "index" => 0 } }, 1)

    assert_equal 1, GameService.turn
    assert_equal 1, GameService.board[0]
  end

  test "check_sign_is_winner? should return true if a player has a winning combination" do
    GameService.board_update(0, 1)
    GameService.board_update(1, 1)
    GameService.board_update(2, 1)

    assert_equal true, @game_service.check_sign_is_winner?(1)
  end

  test "check_sign_is_winner? should return false if no player has a winning combination" do
    GameService.board_update(0, 1)
    GameService.board_update(1, 2)
    GameService.board_update(2, 1)

    assert_equal false, @game_service.check_sign_is_winner?(1)
  end

  test "check_sign_is_winner? should return false if there are no winning combinations" do
    GameService.board_update(0, 1)
    GameService.board_update(1, 2)
    GameService.board_update(2, 1)

    assert_equal false, @game_service.check_sign_is_winner?(2)
  end

  test "find_indexes_of_elements should return an array of indexes of the specified value" do
    GameService.board_update(0, 1)
    GameService.board_update(1, 2)
    GameService.board_update(2, 1)
    GameService.board_update(3, 2)

    indexes = @game_service.find_indexes_of_elements(1)

    assert_equal [0, 2], indexes
  end

  test "reset_game should reset the game state" do
    GameService.board_update(0, 1)
    GameService.board_update(1, 2)
    GameService.player1_update({ "name" => "Player 1", "connection_id" => 1 })
    GameService.player2_update({ "name" => "Player 2", "connection_id" => 2 })
    GameService.player_count_update(2)
    GameService.turn_update(2)

    GameService.reset_game

    assert_equal [""] * 9, GameService.board
    assert_equal 1, GameService.turn
  end
end
