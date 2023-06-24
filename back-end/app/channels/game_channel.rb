class GameChannel < ApplicationCable::Channel
  @@game_service = GameService.new(self)

  def subscribed
    connection_id = self.connection.__id__
    name = params["name"]

    joined = @@game_service.join_game(name, connection_id)
    if joined
      stream_from "game_channel"
      notify_update
    end
  end

  def unsubscribed
    stop_all_streams

    connection_id = self.connection.__id__
    @@game_service.leave_game(connection_id)
  end

  def put_sign(payload)
    connection_id = self.connection.__id__
    @@game_service.put_sign(payload, connection_id)
  end

  def reset_game
    @@game_service.reset_game
  end

  def notify_update
    params = @@game_service.get_params
    ActionCable.server.broadcast "game_channel", params
    transmit(params, via: "game_channel")
  end
end
