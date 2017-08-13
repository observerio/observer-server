import Ember from 'ember';
import { storageFor } from 'ember-local-storage';

const { set, get } = Ember;

export default Ember.Component.extend({
  session: storageFor('session'),
  remember: false,

  actions: {
    login: function(model) {
      let remember = get(this, 'remember');

      if (remember) {
        set(this, 'session.token', model.token);
      }

      get(this, 'go')()
    }
  }
});
