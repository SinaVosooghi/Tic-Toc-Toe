import Component from '@ember/component';
import { action } from '@ember/object';
import { inject as service } from '@ember/service';

export default class GameOverDialogComponent extends Component {
  @service gameService;

  @action
  resetGame() {
    this.gameService.resetGame();
  }

  @action
  leaveGame() {
    this.gameService.leaveGame();
  }
}
