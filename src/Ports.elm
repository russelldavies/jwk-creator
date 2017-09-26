port module Ports exposing (convertToJwk, receiveJwk)

import Json.Encode exposing (Value)


port convertToJwk : ( String, Value ) -> Cmd msg


port receiveJwk : (Value -> msg) -> Sub msg
