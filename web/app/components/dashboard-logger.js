import Ember from 'ember';

const {get, set} = Ember;

export default Ember.Component.extend({
  tagName:'',

  actions: {
    clearAll: function() {
      const logs = get(this, 'logs');
      logs.clear();
      set(this, 'logs', logs);
    }
  }
});
