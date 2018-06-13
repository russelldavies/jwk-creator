import { pem2jwk } from "pem-jwk";
import { js_beautify } from "js-beautify";
import "purecss";
import "./styles.css";

const Elm = require("Main.elm");
const app = Elm.Main.fullscreen();

app.ports.convertToJwk.subscribe(function(args) {
  let [key, extras] = args;
  try {
    let jwk = pem2jwk(key, extras);
    console.log(jwk);
    app.ports.receiveJwk.send(
      js_beautify(JSON.stringify(jwk), { indent_size: 2 })
    );
  } catch (e) {
    app.ports.receiveJwk.send("Invalid input");
  }
});
