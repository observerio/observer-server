import Ember from 'ember';
const { get } = Ember;

export default Ember.Component.extend({
  tagName:'',

  actions: {
    signout: function() {
      get(this, 'go')()
    }
  }
});
