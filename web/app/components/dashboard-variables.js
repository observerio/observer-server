import Ember from 'ember';

export default Ember.Component.extend({
    actions: {
        confirm: function() {
            this.sendAction('sendMessage', {
                vars: ['1'],
            });
        },

        confirmAll: function() {
            this.sendAction('sendMessage', {
                vars: ['1', '2'],
            });
        }
    }
});
