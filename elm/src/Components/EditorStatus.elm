module Components.EditorStatus exposing (..)

import Element exposing (..)
import Element.Font as Font
import Element.Background as Background
import Ace as Editor
import Theme exposing (..)
import Components.FileBrowser as FileBrowser
import Debug exposing (toString)


statusElement s =
    el [ centerY ] (text s)


saveStatus fb session =
    let
        mfile =
            FileBrowser.getFile session fb
    in
        case mfile of
            Nothing ->
                FileBrowser.Unsaved

            Just file ->
                file.status


saveStr fb session =
    case (saveStatus fb session) of
        FileBrowser.Saved ->
            ""

        FileBrowser.Unsaved ->
            "*"


viewSession : FileBrowser.Model -> Editor.EditorState -> Element msg
viewSession fb editor =
    let
        activeSession =
            editor.activeSession
    in
        el
            [ Font.color grey
            , Font.size 14
            , mouseOver [ Background.color appBgColorLight ]
            , height fill
            , padding 3
            ]
            (statusElement (activeSession ++ (saveStr fb activeSession)))


viewCursor : Editor.EditorState -> Element msg
viewCursor editor =
    let
        ( r, c ) =
            editor.cursor
    in
        el
            [ Font.color grey
            , mouseOver [ Background.color appBgColorLight ]
            , Font.size 14
            , height fill
            , padding 3
            ]
            (statusElement <| (toString r) ++ ":" ++ (toString c))
