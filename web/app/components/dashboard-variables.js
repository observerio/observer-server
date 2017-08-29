import Ember from 'ember';

const {get, inject} = Ember;

export default Ember.Component.extend({
  spinner: inject.service('spinner'),

  tagName:'',

  // actions
  sendMessage: null,

  // variables
  vars: [],

  didInsertElement() {
    this._super(...arguments);
    this.get('spinner').show('dashboard-vars-spinner');
  },

  didUpdate() {
    this._super(...arguments);

    let vars = get(this, 'vars');
    if (vars.length > 0) {
      this.get('spinner').hide('dashboard-vars-spinner');
    }
  },

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
