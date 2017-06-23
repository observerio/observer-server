import Ember from 'ember';

export default Ember.Service.extend(Ember.Evented, {
    sendMessage(message) {
        this.trigger('sendMessage', message);
    }
});
