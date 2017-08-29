import Ember from 'ember';
import { storageFor } from 'ember-local-storage';

const { set, get } = Ember;

export default Ember.Component.extend({
  tagName:'',

  session: storageFor('session'),
  remember: false,

  actions: {
    login: function(model) {
      let remember = get(this, 'remember');

      if (remember) {
        set(this, 'session.token', model.token);
      }

      // navigate to dashboard page when
      // we have already logged in
      get(this, 'go')()
    }
  }
});
