import Ember from 'ember';
import { storageFor } from 'ember-local-storage';

const { get, set } = Ember;

export default Ember.Route.extend({
  session: storageFor('session'),

  model(params) {
    return {
      token: params.token
    }
  },

  actions: {
    signout() {
      let session = get(this, 'session');
      set(session, 'token', null);
      this.transitionTo('login');
    }
  }
});
