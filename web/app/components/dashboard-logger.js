import Ember from 'ember';
import DashboardBase from 'observer-web-ember/components/dashboard-base'

export default DashboardBase.extend({
    websockets: Ember.inject.service(),
    socketClient: null,

    didInsertElement() {
        this._super(...arguments);

        const socket = this.get('socketClient');
        socket.on('message', this.messageHandler, this);
    },

    willDestroyElement() {
        const socket = this.get('socketClient');
        socket.off('message', this.messageHandler);

        this._super(...arguments);
    },

    messageHandler(event) {
        Ember.Logger.info(event);
    }
});
