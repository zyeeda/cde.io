// Generated by CoffeeScript 1.3.3
(function() {
  var coala, createService, paths, type, _ref;

  createService = require('coala/service').createService;

  _ref = require('coala/util'), type = _ref.type, paths = _ref.paths;

  coala = require('coala/config').coala;

  exports.handler = function(context, attributes, fn, args) {
    var clazz, manager, managers, name, names, service, _i, _len;
    service = createService();
    managers = [];
    for (_i = 0, _len = attributes.length; _i < _len; _i++) {
      clazz = attributes[_i];
      if (type(clazz) === 'string') {
        names = clazz.split(coala.servicePathSeperator);
        if (names.length !== 2) {
          throw new Error("illegal manager path: " + m + ", module:managerName");
        }
        name = paths.join(names[0], coala.managerFolderName, names[1]);
        manager = require(name).createManager();
        managers.push(manager);
      } else {
        managers.push(service.createManager(clazz));
      }
    }
    args = managers.concat(args);
    return fn.apply(null, args);
  };

}).call(this);
