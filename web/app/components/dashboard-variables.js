import Ember from 'ember';

const {get, set} = Ember;

export default Ember.Component.extend({
  // actions
  sendMessage: null,

  // variables
  vars: [],

  actions: {
    confirm: function(v) {
      get(this, 'sendMessage')({event: 'vars', data: { vars: v }});
    },

    confirmAll: function() {
      const vars = get(this, 'vars');
      get(this, 'sendMessage')({event: 'vars', data: { vars: vars }});
    }
  }
});
