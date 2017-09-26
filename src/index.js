'use strict';

require("./styles.scss");

var pem2jwk = require('pem-jwk').pem2jwk
var beautify = require('js-beautify').js_beautify

var Elm = require('./Main');
var app = Elm.Main.fullscreen();


app.ports.convertToJwk.subscribe(function(args) {
  let [ key, extras ] = args
  let jwk = pem2jwk(key, extras)
  app.ports.receiveJwk.send(beautify(JSON.stringify(jwk), { indent_size: 2 }))
});
