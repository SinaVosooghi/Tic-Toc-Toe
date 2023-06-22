// app/components/tic-tac-toe.js

import Component from '@ember/component';
import { inject as service } from '@ember/service';
import { action } from '@ember/object';

export default class TicTacToeComponent extends Component {
  @service gameService;

  constructor() {
    super(...arguments);
  }

  @action
  putSign(index) {
    this.gameService.putSign(index);
  }
}
