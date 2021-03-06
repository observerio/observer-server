import Ember from "ember";
import { storageFor } from 'ember-local-storage';

const { get } = Ember;

export default Ember.Route.extend({
  session: storageFor('session'),

  beforeModel() {
    let session = get(this, 'session');

    if (this.isAuthenticated()) {
      let token = get(session, 'token');
      this.transitionTo("dashboard", { token: token }) ;
    } else {
      this.transitionTo("login");
    }
  },

  isAuthenticated() {
    let session = get(this, 'session');
    return get(session, 'token') != null;
  },

  init() {
    this._super(...arguments);

    Ember.run.schedule("afterRender",this,function() {
      Ember.$.AdminLTE.layout.fix();
    });
  }
});
