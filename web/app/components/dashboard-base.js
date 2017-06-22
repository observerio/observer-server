import Ember from 'ember';
import ENV from 'observer-web-ember/config/environment';

const {get, set} = Ember;

const Var = Ember.Object.extend({
    type: null,
    value: null,
    name: null
});

const Log = Ember.Object.extend({
    timestamp: null,
    message: null
})

export default Ember.Component.extend({
    websockets: Ember.inject.service(),

    // refs
    socketClient: null,

    // properties
    token: null,

    // variables
    logs: [],
    vars: [],

    didInsertElement() {
        this._super(...arguments);

        const socket = this.get('websockets').socketFor(ENV.WS.HOST);

        socket.on('open', this.openHandler, this);
        socket.on('close', this.closeHandler, this);
        socket.on('message', this.messageHandler, this);

        this.set('socketClient', socket);
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
        const message = { event: 'init', data: { key: get(this, 'token') } };
        socket.send(JSON.stringify(message));
        Ember.Logger.info(event);
    },

    closeHandler(event) {
        const socket = this.get('socketClient');
        Ember.run.later(this, () => socket.reconnect(), 1000);
    },

    _processMessage(event) {
        Ember.Logger.info(event);
        return JSON.parse(event);
    },

    messageHandler(event) {
        const message = this._processMessage(event.data)

        switch(message.type) {
            case 'logs':
                let logs = get(this, 'logs');
                message.logs.forEach((log) => logs.push(Log.create(log)))
                set(this, 'logs', logs);
                break;
            case 'vars':
                let vars = message.vars.reduce((vars, v, index) => {
                    // [key1, value1, key2, value2]
                    if (index % 2 == 0) {
                        let values = v.split(':');
                        let name = values[0];
                        let property = values[1];
                        if (Ember.isBlank(vars[name])) {
                            vars[name] = vars[name] || {};
                            vars[name].name = name;
                        }
                        vars[name][property] = message.vars[index + 1];
                    }
                    return vars;
                }, {});

                let vs = [];
                for(let k in vars) {
                    vs.push(Var.create(vars[k]));
                }
                set(this, 'vars', vs);

                break;
            default:
                Ember.Logger.error(`[dashboard-base] can't parse socket message: ${message}`);
        };
    }
});
