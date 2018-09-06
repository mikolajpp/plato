module SplitPane exposing (..)

import Drag exposing (..)
import DragElem exposing (InterLoc)


type alias Position =
    { x : Int
    , y : Int
    }


type Orientation
    = Horizontal
    | Vertical


type alias Model =
    { dragState : Drag.State InterLoc
    , start : Position
    , end : Position
    , delta : Position
    , oldDelta : Position
    , orient : Orientation
    }


init : Int -> Orientation -> Model
init key orient =
    { dragState = Drag.init
    , start = { x = 0, y = 0 }
    , end = { x = 0, y = 0 }
    , delta = { x = 0, y = 0 }
    , oldDelta = { x = 0, y = 0 }
    , orient = orient
    }


computeDelta : Position -> Position -> Position
computeDelta start end =
    { x = end.x - start.x, y = end.y - start.y }


addPos : Position -> Position -> Position
addPos p1 p2 =
    { x = p1.x + p2.x, y = p1.y + p2.y }


update : Drag.Msg InterLoc -> Model -> Model
update msg model =
    case msg of
        (Drag.Start _ pos) as dragMsg ->
            { model | start = pos, dragState = Drag.update msg model.dragState }

        (Drag.End _ pos) as dragMsg ->
            let
                newdelta =
                    addPos model.oldDelta <|
                        computeDelta model.start pos
            in
                { model
                    | delta = newdelta
                    , oldDelta = newdelta
                    , dragState = Drag.update msg model.dragState
                }

        (Drag.Moved _ pos) as dragMsg ->
            { model
                | end = pos
                , delta = addPos model.oldDelta <| computeDelta model.start pos
                , dragState = Drag.update msg model.dragState
            }

        _ ->
            model
