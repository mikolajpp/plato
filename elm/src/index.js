'use strict';

import 'assets/plato-logo.svg';
var acePort = require("acePort");
const {Elm} = require("./Main.elm");

var app = Elm.Main.init({flags: ""});
acePort.init(app);
