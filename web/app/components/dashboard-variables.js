import Ember from 'ember';

const {get} = Ember;

export default Ember.Component.extend({
  tagName:'',

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
