// Generated by CoffeeScript 1.4.0
var Simple, createManager, mark, ok;

createManager = require('cdeio/manager').createManager;

mark = require('cdeio/mark').mark;

ok = require('assert').ok;

Simple = com.zyeeda.cdeio.tests.entities.Simple;

exports.beforeModule = function(context) {
  return context.jdbc.execute("insert into test_simple(F_ID, F_NAME) values('11', 'simple1')");
};

exports.afterModule = function(context) {
  return context.jdbc.execute('delete from test_simple');
};

exports.testGet = mark('cdeio/test/open-em').on(function() {
  var manager, simple;
  manager = createManager(Simple);
  simple = manager.find('11');
  ok(simple !== null);
  return ok(simple.name === 'simple1');
});