import Ember from 'ember';
import ENV from 'observer-web-ember/config/environment';
import debugLogger from 'ember-debug-logger';

const {get, set} = Ember;
const {later} = Ember.run;

const Var = Ember.Object.extend({
  type: null,
  value: null,
  name: null
});

const Log = Ember.Object.extend({
  timestamp: null,
  message: null
});

export default Ember.Component.extend({
  tagName:'',

  debug: debugLogger(),

  websockets: Ember.inject.service(),

  // refs
  socketClient: null,

  // properties
  token: null, // /:token route

  // variables
  logs: [],
  vars: [],

  LOG_HISTORY: 200,

  didInsertElement() {
    this._super(...arguments);

    const socket = this.get('websockets').socketFor(ENV.WS.HOST);
    socket.on('open', this.openHandler, this);
    socket.on('close', this.closeHandler, this);
    socket.on('message', this.messageHandler, this);
    set(this, 'socketClient', socket);
  },

  willDestroyElement() {
    this._super(...arguments);

    const socket = this.get('socketClient');
    socket.off('open', this.openHandler);
    socket.off('close', this.closeHandler);
    socket.off('message', this.messageHandler);
  },

  openHandler(event) {
    const socket = this.get('socketClient');
    const message = { event: 'init', data: { token: get(this, 'token') } };
    socket.send(JSON.stringify(message));
    this.debug(event);
  },

  closeHandler() {
    const socket = this.get('socketClient');
    later(this, () => socket.reconnect(), 1000);
  },

  _processMessage(event) {
    this.debug(event);
    return JSON.parse(event);
  },

  _processVars(message) {
    let vars = Ember.A(get(this, 'vars'));

    // Lets mark all the variables to delete to clean up the older
    // variables that out of our context.
    // TODO: Later move these variables to history table to ensure that
    // in case of coming the new variables we should restore the values
    // from the history table.
    vars.forEach((v) => {
      v.deleteRecord = true;
      v.newRecord = false;
    });

    Ember.A(message.vars).forEach((v, index) => {
      // [key1, value1, key2, value2]
      if (index % 2 == 0) {
        let values = v.split(':');
        let name = values[0];
        let property = values[1];

        let o = vars.findBy('name', name);
        if (Ember.isBlank(o)) {
          let attributes = {
            name: name,
            readonly: {
              name: `${name}_readonly`
            },
            deleteRecord: false,
            newRecord: true
          };
          attributes[property] = message.vars[index + 1];
          attributes.readonly[property] = message.vars[index + 1];

          let newVar = Var.create(attributes);
          vars.push(newVar);
        } else {
          // in case if we have new record we should set the other properties like value
          // that's coming after the var creation in the block above.
          if (o.get('newRecord')) {
            o.set(property, message.vars[index + 1]);
          }
          o.set(`readonly.${property}`, message.vars[index + 1]);
          o.set('deleteRecord', false);
        }
      }

      return vars;
    });

    vars = vars.rejectBy('deleteRecord', true);

    set(this, 'vars', vars);
  },

  _processLogs(message) {
    let logs = Ember.A(get(this, 'logs'));
    logs = logs.concat(message.logs.map((log) => Log.create(log)));

    if (logs.length > this.LOG_HISTORY) {
      logs = logs.slice(logs.length - this.LOG_HISTORY);
    }
    set(this, 'logs', logs);
  },

  messageHandler(event) {
    const message = this._processMessage(event.data);

    switch(message.type) {
      case 'logs': {
        this._processLogs(message);
        break;
      }
      case 'vars': {
        this._processVars(message);
        break;
      }
      default: {
        Ember.Logger.error(`[dashboard-base] can't parse socket message: ${message}`);
      }
    }
  },

  actions: {
    sendMessage(message) {
      message.data = message.data || {};
      message.data.token = get(this, 'token');

      this.debug(message);
      const socket = get(this, 'socketClient');
      socket.send(JSON.stringify(message));
    }
  }
});
