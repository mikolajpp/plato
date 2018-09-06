port module Ace.Port exposing (..)

import Json.Encode as E
import Json.Decode as Decode
import String
import Html
import Html.Attributes
import Html.Keyed as Keyed
import Element
import Debug exposing (toString)
import Ace exposing (..)


{-| Spawn Ace editor on a given node at given #id.
-}
toSend : Outgoing -> Decode.Value
toSend o =
    case o of
        Spawn editorId ->
            E.object
                [ ( "call", E.string "spawn" )
                , ( "id", E.string editorId )
                ]

        GetContent editorId ->
            E.object
                [ ( "call", E.string "get-content" )
                , ( "id", E.string editorId )
                ]

        SetContent editorId content ->
            E.object
                [ ( "call", E.string "set-content" )
                , ( "id", E.string editorId )
                , ( "content", E.string content )
                ]

        Lock editorId ->
            E.object
                [ ( "call", E.string "lock" )
                , ( "id", E.string editorId )
                ]

        Resize editorId ->
            E.object
                [ ( "call", E.string "resize" )
                , ( "id", E.string editorId )
                ]

        Annotate editorId annotation ->
            E.object
                [ ( "call", E.string "annotate" )
                , ( "id", E.string editorId )
                , ( "column", E.int annotation.col )
                , ( "row", E.int annotation.row )
                , ( "text", E.string annotation.text )
                , ( "type", E.string annotation.typ )
                ]

        ClearAnnotation editorId ->
            E.object
                [ ( "call", E.string "clear-annotation" )
                , ( "id", E.string editorId )
                ]

        ActivateErrorMarker editorId start end ->
            E.object
                [ ( "call", E.string "activate-error-marker" )
                , ( "id", E.string editorId )
                , ( "start"
                  , E.object
                        [ ( "row", E.int <| start.row - 1 )
                        , ( "col", E.int <| start.col - 1 )
                        ]
                  )
                , ( "end"
                  , E.object
                        [ ( "row", E.int <| end.row - 1 )
                        , ( "col", E.int <| end.col - 1 )
                        ]
                  )
                ]

        ClearErrorMarker editorId ->
            E.object
                [ ( "call", E.string "clear-error-marker" )
                , ( "id", E.string editorId )
                ]

        NewSession editorId sessionName content ->
            E.object
                [ ( "call", E.string "new-session" )
                , ( "id", E.string editorId )
                , ( "session_name", E.string sessionName )
                , ( "content", E.string content )
                ]

        ChangeSession editorId sessionName ->
            E.object
                [ ( "call", E.string "change-session" )
                , ( "id", E.string editorId )
                , ( "session_name", E.string sessionName )
                ]

        DeleteSession editorId sessionName ->
            E.object
                [ ( "call", E.string "delete-session" )
                , ( "id", E.string editorId )
                , ( "session_name", E.string sessionName )
                ]


port send : E.Value -> Cmd msg


editorSend : Outgoing -> Cmd msg
editorSend out =
    send <| toSend out


port recv : (Decode.Value -> msg) -> Sub msg


type alias Payload =
    { call : String
    , id : String
    , content : Maybe String
    , sessionName : Maybe String
    , row : Maybe Int
    , col : Maybe Int
    }


payloadDec : Decode.Decoder Payload
payloadDec =
    Decode.map6 Payload
        (Decode.field "call" Decode.string)
        (Decode.field "id" Decode.string)
        (Decode.field "content" (Decode.maybe Decode.string))
        (Decode.field "session_name" (Decode.maybe Decode.string))
        (Decode.field "row" (Decode.maybe Decode.int))
        (Decode.field "col" (Decode.maybe Decode.int))


editorRecv : Decode.Value -> Incoming
editorRecv val =
    let
        result =
            Decode.decodeValue payloadDec val
    in
        case
            result
        of
            Ok payload ->
                case
                    payload.call
                of
                    "spawn" ->
                        Spawned payload.id

                    "get-content" ->
                        Content payload.id payload.content

                    "new-session" ->
                        SessionCreated payload.id (Maybe.withDefault "" payload.sessionName)

                    "delete-session" ->
                        SessionDeleted payload.id (Maybe.withDefault "" payload.sessionName)

                    "change-session" ->
                        SessionChanged payload.id (Maybe.withDefault "" payload.sessionName)

                    "change-cursor" ->
                        CursorChanged payload.id
                            ( (Maybe.withDefault 0 payload.row)
                            , (Maybe.withDefault 0 payload.col)
                            )

                    callName ->
                        Failure <| "Unknown call '" ++ callName ++ "'"

            Err err ->
                Failure <| toString err
