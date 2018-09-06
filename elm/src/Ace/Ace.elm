module Ace exposing (..)

import Json.Encode as Encode
import Json.Decode as Decode
import String
import Html
import Html.Attributes exposing (style)
import Html.Keyed as Keyed
import Element
import Dict


type alias Annotation =
    { row : Int
    , col : Int
    , text : String
    , typ : String
    }


type alias Location =
    { row : Int
    , col : Int
    }



-- first argument is always editor ID


type Outgoing
    = Spawn String
    | GetContent String
    | SetContent String String -- Content string
    | Lock String
    | Resize String
    | Annotate String Annotation
    | ClearAnnotation String
    | ActivateErrorMarker String Location Location
    | ClearErrorMarker String
    | NewSession String String String -- New session 'name' with 'content'
    | ChangeSession String String -- Switches to session 'name'
    | DeleteSession String String -- Destroys session 'name' (first switch to new session)


type Incoming
    = Spawned String
    | Content String (Maybe String)
    | SessionCreated String String
    | SessionDeleted String String
    | SessionChanged String String
    | CursorChanged String ( Int, Int )
    | Failure String


type alias EditorOptions =
    { lock : Bool
    }


type alias Session =
    { content : String
    }


type alias EditorState =
    { sessions : Dict.Dict String Session
    , activeSession : String
    , cursor : ( Int, Int )
    }


initEditorState =
    { sessions = Dict.empty
    , activeSession = ""
    , cursor = ( 1, 1 )
    }


setEditorSession name model =
    { model | activeSession = name }


setEditorCursor newpos model =
    { model | cursor = newpos }


createEditorSession name model =
    let
        newSessions =
            Dict.insert name { content = "" } model.sessions
    in
        { model | sessions = newSessions }


deleteEditorSession name model =
    let
        newSessions =
            Dict.remove name model.sessions
    in
        { model | sessions = newSessions }


setEditorContent : String -> EditorState -> EditorState
setEditorContent content model =
    let
        newSessions =
            Dict.insert model.activeSession { content = content } model.sessions
    in
        { model | sessions = newSessions }


type alias Model =
    { editors : Dict.Dict String EditorState
    , status : String
    }


getEditor id model =
    Maybe.withDefault initEditorState <|
        Dict.get id model.editors


updateEditor model id operation =
    let
        editor =
            getEditor id model
    in
        { model
            | editors =
                Dict.insert id (operation editor) model.editors
        }


update : Incoming -> Model -> ( Model, Cmd msg )
update msg model =
    case msg of
        Spawned id ->
            ( { model | editors = Dict.insert id initEditorState model.editors }
            , Cmd.none
            )

        Content id content ->
            ( (updateEditor model id (setEditorContent (Maybe.withDefault "" content)))
            , Cmd.none
            )

        SessionCreated id sessionName ->
            ( (updateEditor model id (createEditorSession sessionName))
            , Cmd.none
            )

        SessionDeleted id sessionName ->
            ( (updateEditor model id (deleteEditorSession sessionName))
            , Cmd.none
            )

        SessionChanged id sessionName ->
            ( (updateEditor model id (setEditorSession sessionName))
            , Cmd.none
            )

        CursorChanged id pos ->
            ( (updateEditor model id (setEditorCursor pos)), Cmd.none )

        Failure err ->
            ( { model | status = "Ace error: " ++ err }, Cmd.none )


initEditor =
    { editors = Dict.empty, status = "" }


getContent id model =
    let
        editor =
            Dict.get id model.editors
    in
        case editor of
            Just e ->
                case Dict.get e.activeSession e.sessions of
                    Just s ->
                        s.content

                    Nothing ->
                        ""

            Nothing ->
                ""


editorEl : String -> Element.Element msg
editorEl id =
    (Element.html <|
        (Keyed.node "div"
            [ style "width" "100%"
            , style "height" "100%"
            , Html.Attributes.id id
            ]
            []
        )
    )
