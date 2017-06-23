import Ember from 'ember';

const {get, set} = Ember;

export default Ember.Component.extend({
    dashboardSocket: Ember.inject.service(),

    actions: {
        confirm: function() {
            get(this, 'dashboardSocket').sendMessage({
                vars: ['1']
            });
        },

        confirmAll: function() {
            get(this, 'dashboardSocket').sendMessage({
                vars: ['1']
            });
        }
    }
});
