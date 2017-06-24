import Ember from 'ember';

const {get, set} = Ember;

export default Ember.Component.extend({
    // actions
    sendMessage: null,

    actions: {
        confirm: function() {
            get(this, 'sendMessage')({
                vars: ['1']
            });
        },

        confirmAll: function() {
            get(this, 'sendMessage')({
                vars: ['1']
            });
        }
    }
});
