import Ember from 'ember';
import ENV from 'observer-web-ember/config/environment';

export default Ember.Component.extend({
    websockets: Ember.inject.service(),
    socketClient: null,

    didInsertElement() {
        this._super(...arguments);

        const socket = this.get('websockets').socketFor(ENV.WS.HOST);

        socket.on('open', this.openHandler, this);
        socket.on('message', this.messageHandler, this);
        socket.on('close', this.closeHandler, this);

        this.set('socketClient', socket);
    },

    willDestroyElement() {
        this._super(...arguments);

        const socket = this.get('socketClient');

        /*
          4. The final step is to remove all of the listeners you have setup.
          */
        socket.off('open', this.openHandler);
        socket.off('message', this.messageHandler);
        socket.off('close', this.closeHandler);
    },

    openHandler(event) {
        Ember.Logger.info(event);
    },

    messageHandler(event) {
        Ember.Logger.info(event);
    },

    closeHandler(event) {
        Ember.Logger.info(event);
    },

    actions: {
        sendButtonPressed() {
            const socket = this.get('socketClient');
            socket.send('Hello Websocket World');
        }
    }
});
