module View exposing (view)

import Update exposing (Msg(..))
import Browser
import Html exposing (Html)
import Html.Attributes exposing (style)
import Html.Keyed as Keyed
import Element exposing (..)
import Element.Background as Background
import Element.Input as Input
import Element.Events as Events
import Element.Border as Border
import Element.Font as Font
import DragElem
import Drag
import Ace as Editor
import SplitPane
import Urb.Ship
import Components.FileBrowser as FileBrowser
import Components.EditorStatus as EditorStatus


--import FeatherIcons

import Theme exposing (..)


editorLogo =
    el
        [ width (px 40)
        , height (px 40)
        , Background.image "http://cdn.urbitetorbi.org/dist/plato-logo.svg"
        ]
        none



-- Editor Controls
--runIcon =
--Element.html
--(FeatherIcons.play
--|> FeatherIcons.toHtml
--[ style "width" "20px"
--, style "height" "20px"
--]
--)
--checkIcon =
--Element.html
--(FeatherIcons.checkCircle
--|> FeatherIcons.toHtml
--[ style "width" "20px"
--, style "height" "20px"
--]
--)
--newFileIcon =
--Element.html
--(FeatherIcons.filePlus
--|> FeatherIcons.toHtml
--[ style "width" "20px"
--, style "height" "20px"
--]
--)
--saveFileIcon =
--Element.html
--(FeatherIcons.save
--|> FeatherIcons.toHtml
--[ style "width" "20px"
--, style "height" "20px"
--]
--)


runButton =
    row [ spacing 5 ]
        [ --runIcon,
          (text "Run")
        ]


checkButton =
    row [ spacing 5 ]
        [ --checkIcon,
          (text "Check")
        ]


newFileButton =
    row [ spacing 5, Font.color grey ]
        [ --newFileIcon,
          (text "New")
        ]


saveFileButton =
    row [ spacing 5, Font.color grey ]
        [ --saveFileIcon,
          (text "Save")
        ]


buttons =
    [ ( newFileButton, Update.RunClicked )
    , ( saveFileButton, Update.RunClicked )
    , ( runButton, Update.RunClicked )
    ]


buttonBottomHighlight =
    [ Border.widthEach { bottom = 2, left = 0, right = 0, top = 0 }
    , Border.color appBgColorDark
    , mouseOver [ Border.color buttonHighlightColor ]
    ]


headerButtons buttonList =
    List.map
        (\( bel, action ) ->
            el
                ([ Events.onClick action, alignLeft, pointer, height fill, Font.color white ] ++ buttonBottomHighlight)
                (el
                    [ centerY
                    , Font.size 18
                    ]
                    bel
                )
        )
        buttonList


authStatus : Urb.Ship.Ship -> Element Update.Msg
authStatus ship =
    let
        classColor =
            case ship.class of
                Urb.Ship.Anon ->
                    yellow

                _ ->
                    identityColor
    in
        el
            [ centerY
            , Font.size 15
            , Font.color classColor
            , Background.color appBgColorDark
            , Border.rounded 2
            , Border.color classColor
            , Border.solid
            , Border.width 1
            , alignRight
            , padding 2
            ]
            (text ("~" ++ ship.shortAddress))



-- Color palette


showBorder =
    [ Border.width 1, Border.rounded 2, Border.color darkBlue ]


editorBorder =
    [ Border.widthEach { bottom = 0, left = 1, right = 0, top = 0 }, Border.color appBgColorLight ]



-- Sizes


fileBrowserWidth : Int
fileBrowserWidth =
    200


fileBrowserHeight : Update.Model -> Int
fileBrowserHeight model =
    model.windowSize.height - 60 - 40


editorWidth model =
    if model.windowSize.width > 0 then
        width <|
            px <|
                (model.windowSize.width - fileBrowserWidth)
                    // 2
                    + (model.splitPane.delta.x)
    else
        width fill



--activityIcon =
--Element.html
--(FeatherIcons.activity
--|> FeatherIcons.toHtml
--[ style "width" "14px"
--, style "height" "14px"
--, style "color" "grey"
--]
--)


viewStatus status =
    let
        s =
            if (String.length status) > 0 && (status /= "Ok") then
                status ++ "..."
            else
                status
    in
        el
            [ Font.size 14
            , Font.color grey
            , alignLeft
            , mouseOver [ Background.color appBgColorLight ]
            , height fill
            , padding 3
            ]
        <|
            row [ centerY ]
                [ --activityIcon,
                  el
                    [ centerY ]
                    (text s)
                ]


view : Update.Model -> Browser.Document Update.Msg
view model =
    let
        editor =
            Editor.getEditor "editor" model.editor

        site =
            layout
                [ appFont, Background.color appBgColor, width fill, height fill ]
            <|
                column [ height fill, width fill ]
                    [ -- TOP BAR
                      (row
                        [ height (px 60), width fill, Background.color appBgColorDark ]
                        [ row [ spacing 20, paddingXY 5 0, height fill ]
                            (editorLogo
                                :: headerButtons buttons
                            )
                        , row [ padding 5, alignRight ]
                            [ authStatus model.urb.ship ]
                        ]
                      )
                    , row [ height fill, centerY, width fill ]
                        -- FILE BROWSER
                        ([ el
                            [ width (px fileBrowserWidth)
                            , height (px (fileBrowserHeight model))
                            , scrollbarY
                            , alignTop
                            , Background.color appBgColor
                            ]
                           <|
                            FileBrowser.view model.fileBrowser
                         , -- TEXT EDITOR
                           el
                            ([ height fill
                             , editorWidth model
                             , paddingXY 2 0
                             ]
                                ++ editorBorder
                            )
                           <|
                            Editor.editorEl
                                "editor"
                         , -- OUTPUT
                           el
                            ([ height fill
                             , width (px 10)
                             , Background.color appBgColor
                             , pointer
                             , htmlAttribute <| Html.Attributes.draggable "auto"
                             , htmlAttribute <|
                                Html.Attributes.map DragMsg <|
                                    Drag.onMouseDownWithOptions
                                        { stopPropagation = True
                                        , preventDefault = True
                                        }
                                    <|
                                        (DragElem.SplitPane 0)

                             --, Events.onMouseDown <| SplitPane.grab model.splitPane
                             -- , Events.onMouseUp <| SplitPane.release model.splitPane
                             ]
                                ++ editorBorder
                            )
                            none
                         , el
                            ([ height fill, width fill, paddingXY 2 0 ])
                           <|
                            Editor.editorEl
                                "terminal"
                         ]
                        )
                    , row [ height (px 40), width fill, Background.color appBgColorDark ]
                        [ EditorStatus.viewSession model.fileBrowser editor
                        , EditorStatus.viewCursor editor
                        , viewStatus (model.status)

                        -- , el
                        --    [ alignLeft
                        --    , Font.color <|
                        --        if (model.status /= "OK") then
                        --            red
                        --        else
                        --            green
                        --    , Border.rounded 2
                        --    , padding 2
                        --    , Font.size 15
                        --    ]
                        --    (text <| model.status)
                        ]
                    ]
    in
        { title = "Plato - Hoon Editor"
        , body = [ site ]
        }
