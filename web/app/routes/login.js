import Ember from "ember";
import fetch from 'fetch';
import ENV from 'observer-web-ember/config/environment';

export default Ember.Route.extend({
  model() {
      return fetch(`${ENV.APP.HOST}/tokens`)
          .then((response) => response.json())
          .catch((error) => console.error(error));
  }
});
