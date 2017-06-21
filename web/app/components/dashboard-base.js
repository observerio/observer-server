import Ember from 'ember';
import ENV from 'observer-web-ember/config/environment';

const {get, set} = Ember;

export default Ember.Component.extend({
    websockets: Ember.inject.service(),

    // refs
    socketClient: null,

    // properties
    token: null,

    didInsertElement() {
        this._super(...arguments);

        const socket = this.get('websockets').socketFor(ENV.WS.HOST);

        socket.on('open', this.openHandler, this);
        socket.on('close', this.closeHandler, this);

        this.set('socketClient', socket);
    },

    willDestroyElement() {
        this._super(...arguments);

        const socket = this.get('socketClient');
        socket.off('open', this.openHandler);
        socket.off('close', this.closeHandler);
    },

    openHandler(event) {
        const socket = this.get('socketClient');
        const message = { event: 'init', data: { key: get(this, 'token') } };
        socket.send(JSON.stringify(message));
        Ember.Logger.info(event);
    },

    closeHandler(event) {
        const socket = this.get('socketClient');
        Ember.run.later(this, () => socket.reconnect(), 1000);
    }
});
