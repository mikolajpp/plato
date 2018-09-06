module Components.FileBrowser exposing (..)

import Html.Attributes exposing (style)
import Element exposing (..)
import Element.Font as Font
import Element.Background as Background
import List
import String
import Dict


--import FeatherIcons

import Theme exposing (..)


type FileStatus
    = Saved
    | Unsaved


type alias File =
    { filename : String
    , status : FileStatus
    }


testlist =
    [ ( "<vacuum>", { filename = "<vacuum>", status = Unsaved } )
    ]


type alias Model =
    { files : Dict.Dict String File -- The index into editor's sessions
    }


init : Model
init =
    { files = Dict.fromList <| testlist
    }


getFile : String -> Model -> Maybe File
getFile name model =
    Dict.get name model.files



--fileIcon =
--Element.html
--(FeatherIcons.file
--|> FeatherIcons.toHtml
--[ style "width" "14px"
--, style "height" "14px"
--, style "color" "white"
--]
--)


viewFile filename =
    row [ spacing 3, padding 1, mouseOver [ Background.color appBgColorDark ], pointer ]
        [ --fileIcon,
          el [ Font.color white, Font.size 14 ] (text filename)
        ]


viewFiles filelist =
    List.map
        (\filename ->
            viewFile filename
        )
    <|
        filelist


view : Model -> Element msg
view model =
    column [ height fill, width fill ] <|
        viewFiles (List.map .filename (Dict.values model.files))
