import Ember from 'ember';

const {get, set, inject} = Ember;

export default Ember.Component.extend({
  spinner: inject.service('spinner'),

  tagName:'',

  logs: [],

  didInsertElement() {
    this._super(...arguments);
    this.get('spinner').show('dashboard-logs-spinner');
  },

  didUpdate() {
    this._super(...arguments);

    let logs = get(this, 'logs');
    if (logs.length > 0) {
      this.get('spinner').hide('dashboard-logs-spinner');
    }
  },

  actions: {
    clearAll: function() {
      const logs = get(this, 'logs');
      logs.clear();
      set(this, 'logs', logs);
    }
  }
});
