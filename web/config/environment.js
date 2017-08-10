/* eslint-env node */
'use strict';

module.exports = function(environment) {
  let ENV = {
    modulePrefix: 'observer-web-ember',
    environment,
    rootURL: '/',
    locationType: 'auto',
    EmberENV: {
      FEATURES: {
        // Here you can enable experimental features on an ember canary build
        // e.g. 'with-controller': true
      },
      EXTEND_PROTOTYPES: {
        // Prevent Ember Data from overriding Date.parse.
        Date: false
      }
    },

    APP: {
      // Here you can pass flags/options to your application instance
      // when it is created
    },
    //
    // contentSecurityPolicyHeader: 'Content-Security-Policy',
    // contentSecurityPolicy: {
    //   'default-src': "'none'",
    //   'script-src': "'self' 'unsafe-inline' *",
    //   'font-src': "'self' 'unsafe-inline' maxcdn.bootstrapcdn.com fonts.googleapis.com fonts.gstatic.com",
    //   'connect-src': "'self' *",
    //   'img-src': "'self' * data:",
    //   'style-src': "'self' 'unsafe-inline' maxcdn.bootstrapcdn.com fonts.googleapis.com"
    // },

    'ember-websockets': {
      socketIO: true
    }
  };

  if (environment === 'development') {
    ENV.logging_active = true;

    ENV.APP.HOST = "http://localhost:8080";
    ENV.WS = {
        HOST: "ws://127.0.0.1:4000/ws"
    };
    // ENV.APP.LOG_ACTIVE_GENERATION = true;
    // ENV.APP.LOG_TRANSITIONS = true;
    // ENV.APP.LOG_TRANSITIONS_INTERNAL = true;
    // ENV.APP.LOG_VIEW_LOOKUPS = true;
  }

  if (environment === 'test') {
    // Testem prefers this...
    ENV.locationType = 'none';

    // keep test console output quieter
    ENV.APP.LOG_ACTIVE_GENERATION = false;
    ENV.APP.LOG_VIEW_LOOKUPS = false;

    ENV.APP.rootElement = '#ember-testing';
  }

  if (environment === 'production') {
    ENV.APP.HOST = "https://observer.rubyforce.co/api";
    ENV.WS = {
        HOST: "wss://observer.rubyforce.co/ws"
    };
  }

  return ENV;
};
