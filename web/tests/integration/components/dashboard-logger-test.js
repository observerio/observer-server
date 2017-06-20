import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';

moduleForComponent('dashboard-logger', 'Integration | Component | dashboard logger', {
  integration: true
});

test('it renders', function(assert) {
  this.render(hbs`{{dashboard-logger}}`);

  assert.equal(this.$().text().trim(), '');

  // Template block usage:
  this.render(hbs`
    {{#dashboard-logger}}
      template block text
    {{/dashboard-logger}}
  `);

  assert.equal(this.$().text().trim(), 'template block text');
});
