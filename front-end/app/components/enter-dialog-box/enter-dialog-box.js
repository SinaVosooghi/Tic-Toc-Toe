import Component from '@ember/component';
import { action } from '@ember/object';
import { inject as service } from '@ember/service';

export default class EnterDialogBoxComponent extends Component {
  @service gameService;
  playerName = '';

  @action
  enterGame() {
    if (this.playerName === '') {
      alert('Name can not be empty!');
    } else {
      this.gameService.joinGame(this.playerName);
    }
  }
}
