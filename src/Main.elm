module Main exposing (main)

import Html exposing (Html, div, text, textarea, h1, h2, option, select, fieldset, form, legend, input, label, span, a, pre, p)
import Html.Attributes exposing (class, value, type_, id, for, placeholder, style, href)
import Html.Events exposing (onClick, onInput)
import Ports
import Json.Decode as Decode
import Json.Encode as Encode
import Dict exposing (Dict)


(=>) : a -> b -> ( a, b )
(=>) =
    (,)


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


init : ( Model, Cmd Msg )
init =
    { key = ""
    , parameters = Dict.empty
    , jwk = Nothing
    }
        => Cmd.none



-- MODEL


type alias Model =
    { key : String
    , parameters : Dict String String
    , jwk : Maybe String
    }


useOptions : List ( String, String )
useOptions =
    [ ( "sig", "Signing" ), ( "enc", "Encryption" ) ]


algOptions : List ( String, String )
algOptions =
    List.map (\e -> ( e, e )) [ "RS256", "RS384", "RS512", "ES256", "ES384", "ES512" ]



-- UPDATE


type Msg
    = SetParameter String String
    | SetKey String
    | Convert
    | OnJWK (Maybe String)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SetParameter param val ->
            if val == "" then
                { model | parameters = Dict.remove param model.parameters }
                    => Cmd.none
            else
                { model | parameters = Dict.insert param val model.parameters }
                    => Cmd.none

        SetKey key ->
            { model | key = key } => Cmd.none

        Convert ->
            model => Ports.convertToJwk ( model.key, paramsToJson model.parameters )

        OnJWK jwk ->
            { model | jwk = jwk } => Cmd.none


paramsToJson : Dict String String -> Encode.Value
paramsToJson params =
    Dict.toList params
        |> List.map (\( key, val ) -> ( key, Encode.string val ))
        |> Encode.object



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.map OnJWK receiveJwk


receiveJwk : Sub (Maybe String)
receiveJwk =
    Ports.receiveJwk (Decode.decodeValue Decode.string >> Result.toMaybe)



-- VIEW


view : Model -> Html Msg
view model =
    div [ class "pure-g" ]
        [ div [ class "pure-u-1" ]
            [ h1 [] [ text "JWK Creator" ]
            , p []
                [ text "Create a "
                , a [ href "https://tools.ietf.org/html/rfc7517" ] [ text "JSON Web Key (JWK)" ]
                , text " from a public key or certificate."
                ]
            , p []
                [ text "This tool is for existing keys/certs. If you want to generate a new key and the corresponding JWK then use "
                , a [ href "https://mkjwk.org/" ] [ text "mkjwk" ]
                ]
            ]
        , div [ class "pure-u-1-2" ]
            [ h2 [] [ text "Options" ]
            , form [ class "pure-form pure-form-aligned" ]
                [ fieldset []
                    [ div [ class "pure-control-group" ]
                        [ label [ for "use" ] [ text "Public Key Use" ]
                        , select
                            [ id "use"
                            , onInput (SetParameter "use")
                            ]
                            (selectOptions useOptions)
                        ]
                    , div [ class "pure-control-group" ]
                        [ label [ for "alg" ] [ text "Algorithm" ]
                        , select
                            [ id "alg"
                            , onInput (SetParameter "alg")
                            ]
                            (selectOptions algOptions)
                        ]
                    , div [ class "pure-control-group" ]
                        [ label [ for "kid" ] [ text "Key ID" ]
                        , input
                            [ id "kid"
                            , placeholder "(none)"
                            , type_ "text"
                            , onInput (SetParameter "kid")
                            ]
                            []
                        ]
                    , div [ class "pure-control-group" ]
                        [ label [ for "pem" ] [ text "PEM encoded key/cert" ]
                        , textarea
                            [ class "pure-input-1-2"
                            , id "pem"
                            , placeholder sampleKey
                            , onInput SetKey
                            , style [ ( "height", "150px" ) ]
                            ]
                            []
                        ]
                    , div [ class "pure-controls" ]
                        [ a
                            [ class "pure-button pure-button-primary"
                            , onClick Convert
                            ]
                            [ text "Convert" ]
                        ]
                    ]
                ]
            ]
        , div [ class "pure-u-1-2" ]
            [ h2 []
                [ text "JWK" ]
            , pre []
                [ text (Maybe.withDefault "" model.jwk) ]
            ]
        ]


selectOptions : List ( String, String ) -> List (Html msg)
selectOptions options =
    (option [ value "" ] [ text "(unspecified)" ])
        :: List.map (\( val, str ) -> option [ value val ] [ text str ]) options


sampleKey : String
sampleKey =
    """---BEGIN PUBLIC KEY-----
DEADBABECAFE
-----END PUBLIC KEY-----"""
