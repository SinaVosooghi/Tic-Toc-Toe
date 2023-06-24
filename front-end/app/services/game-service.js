import Service from '@ember/service';
import { inject as service } from '@ember/service';
import { tracked } from '@glimmer/tracking';

import environment from 'front-end/config/environment';

export default class GameService extends Service {
  @service websockets;
  @service gameService;

  socketRef = null;
  @tracked currentPlayer = null;
  @tracked player1 = null;
  @tracked player2 = null;
  @tracked gameEnded = false;
  @tracked winner = null;
  @tracked board = null;
  @tracked tie = false;

  constructor() {
    super(...arguments);

    this.subscribe();
  }

  async subscribe() {
    const socket = await this.websockets.socketFor(environment.cable.url);
    console.log('connected to: ', environment.cable.url);

    socket.on('open', () => {}, this);
    socket.on('message', this.handleReceivedMessage, this);
    socket.on('close', () => {}, this);

    this.set('socketRef', socket);
  }

  send(sendContent, callback) {
    const message = JSON.stringify(sendContent);

    this.waitForConnection(() => {
      this.socketRef.send(message);
      if (typeof callback !== 'undefined') {
        callback();
      }
    }, 5000);
  }

  waitForConnection(callback, interval) {
    if (this.socketRef.readyState() === 1) {
      callback();
    } else {
      var that = this;
      // optional: implement backoff for interval here
      setTimeout(function () {
        that.waitForConnection(callback, interval);
      }, interval);
    }
  }

  joinGame(name) {
    console.log('joining game...');
    const sendContent = {
      command: 'subscribe',
      identifier: JSON.stringify({
        channel: 'GameChannel',
        name: `${name}`,
      }),
    };

    this.send(sendContent);
  }

  putSign(index) {
    const sendContent = {
      command: 'message',
      identifier: this.getSocketIdentifier(),
      data: JSON.stringify({
        action: 'put_sign',
        payload: {
          index: String(index),
        },
      }),
    };

    this.send(sendContent);
  }

  resetGame() {
    const sendContent = {
      command: 'message',
      identifier: this.getSocketIdentifier(),
      data: JSON.stringify({
        action: 'reset_game',
      }),
    };

    this.send(sendContent);
    this.setProperties({
      gameEnded: false,
      winner: null,
    });
  }

  leaveGame() {
    const sendContent = {
      command: 'unsubscribe',
      identifier: this.getSocketIdentifier(),
    };

    this.send(sendContent);
    this.setProperties({
      currentPlayer: null,
      player1: null,
      player2: null,
      gameEnded: false,
      winner: null,
      board: null,
    });
  }

  handleReceivedMessage(response) {
    const data = JSON.parse(response?.data);
    const message = data?.message;
    const type = message?.type;
    delete message?.type;

    switch (type) {
      case 'update_game':
        this.handleUpdateGame(message);
        break;
      case 'player_won':
        this.handlePlayerWon(message);
        break;
      default:
        // Handle other message types if necessary
        break;
    }
  }

  handleUpdateGame(payload) {
    this.setProperties(payload);

    if (!this.currentPlayer) {
      this.setCurrentPlayer();
    }
    this.checkGameEnded();
  }

  handlePlayerWon(payload) {
    this.setProperties({
      gameEnded: true,
      winner: this[payload.player].name,
    });
  }

  updateVariable(newValue) {
    this.gameChannel.board = newValue;
  }

  setCurrentPlayer() {
    //if game has 2 player after you joined, you are second player!
    if (this.player2?.name) {
      this.setProperties({
        currentPlayer: this.player2,
      });
    } else {
      this.setProperties({
        currentPlayer: this.player1,
      });
    }
  }

  mapPlayerToSign(player) {
    const mapObject = {
      1: '○',
      2: '✗',
    };

    return mapObject[player];
  }

  getSocketIdentifier() {
    return JSON.stringify({
      channel: 'GameChannel',
      name: `${this.currentPlayer.name}`,
    });
  }

  checkGameEnded() {
    let filledCount = 0;
    this.board.forEach((element) => {
      if (element !== '') {
        filledCount++;
      }
    });

    if (filledCount === 9) {
      this.setProperties({
        gameEnded: true,
      });
    }
  }
}
