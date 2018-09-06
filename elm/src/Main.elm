module Main exposing (..)

import Update exposing (..)
import View exposing (..)
import Html exposing (Html)
import Urb.Urb as Urb
import Ace as Editor
import Ace.Port as EditorPort
import Json.Decode as D
import Json.Encode as E
import Browser
import Browser.Navigation as Nav
import Url exposing (Url)
import Browser.Events as BEvents
import Drag
import DragElem
import Keyboard
import SplitPane


-- MODELS


appView : String -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
appView urbiturl url key =
    init urbiturl


main : Program String Model Msg
main =
    Browser.application
        { init = appView
        , update = update
        , view = view
        , subscriptions = subscriptions
        , onUrlRequest = OnUrlRequest
        , onUrlChange = OnUrlChange
        }



-- SUBSCRIPTIONS


toIncoming : (D.Value -> Editor.Incoming) -> (D.Value -> Msg)
toIncoming recv v =
    Editor <| recv v


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ EditorPort.recv (toIncoming <| EditorPort.editorRecv)

        --, SplitPane.subscriptions model.splitPane
        , BEvents.onResize (\x y -> WindowResize ( x, y ))
        , Sub.map
            KeyMsg
            Keyboard.subscriptions
        , Sub.map DragMsg
            (Drag.subscriptions model.splitPane.dragState)
        ]
