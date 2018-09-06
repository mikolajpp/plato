module Update exposing (..)

import Dict
import Keyboard
import Urb.Urb as Urb
import Urb.Error
import Urb.Conn
import Urb.Auth
import Ace as Editor
import Ace.Port as EditorPort
import Poke.Plato exposing (..)
import SplitPane
import Task
import Components.FileBrowser as FileBrowser
import Debug exposing (toString)
import Keyboard exposing (Key(..))
import Keyboard.Arrows
import Drag
import DragElem
import Browser exposing (UrlRequest)
import Browser.Dom as Dom
import Url exposing (..)


type Msg
    = Nop
    | RunClicked
    | RunProgram
    | SetStatus String
    | Editor Editor.Incoming
    | Urb (Urb.Msg PollType)
    | KeyMsg Keyboard.Msg
    | DragMsg (Drag.Msg DragElem.InterLoc)
    | WindowResize ( Int, Int )
    | ViewportInfo Dom.Viewport
    | OnUrlRequest UrlRequest
    | OnUrlChange Url


type JobStage
    = JobReady
    | JobParse
    | JobCompile
    | JobEval


type alias ProgramState =
    { stage : JobStage
    , content : String
    }


initProgram =
    { stage = JobReady, content = "" }


initPrograms =
    Dict.empty


type alias EditorState =
    { content : String
    }


initEditor =
    { content = "" }


initEditors =
    Dict.empty


type alias Model =
    { urb : Urb.Model Msg Poke.Plato.PollType
    , status : String
    , editor : Editor.Model
    , activeProgram : Int
    , programs : Dict.Dict Int ProgramState
    , pressedKeys : List Key
    , splitPane : SplitPane.Model
    , windowSize : { width : Int, height : Int }
    , fileBrowser : FileBrowser.Model
    }


init : String -> ( Model, Cmd Msg )
init urbiturl =
    let
        ( urbInit, urbCmd ) =
            Urb.init urbiturl Urb codecs
    in
        ( { urb = urbInit
          , status = "Ok"
          , activeProgram = 0
          , programs = initPrograms
          , editor = Editor.initEditor
          , pressedKeys = []
          , splitPane = SplitPane.init 0 SplitPane.Vertical
          , windowSize = { width = 0, height = 0 }
          , fileBrowser = FileBrowser.init
          }
        , Cmd.batch
            [ Task.perform ViewportInfo Dom.getViewport
            , EditorPort.editorSend <| Editor.Spawn "editor"
            , EditorPort.editorSend <| Editor.Spawn "terminal"
            , urbCmd
            ]
        )


getActiveProgram model =
    Maybe.withDefault initProgram (Dict.get model.activeProgram model.programs)


updateActiveProgram model prog =
    Dict.insert model.activeProgram prog model.programs


setActiveProgramStage model stage =
    let
        aprog =
            getActiveProgram model
    in
        updateActiveProgram model { aprog | stage = stage }



-- Keyboard shortcuts


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Nop ->
            ( model, Cmd.none )

        OnUrlRequest _ ->
            ( model, Cmd.none )

        OnUrlChange _ ->
            ( model, Cmd.none )

        KeyMsg kmsg ->
            let
                newKeys =
                    Keyboard.update kmsg model.pressedKeys

                runClicked =
                    if
                        List.member Control newKeys
                            && List.member Enter newKeys
                    then
                        True
                    else
                        False
            in
                if runClicked then
                    ( { model
                        | programs = (setActiveProgramStage model JobParse)
                        , status = "Compiling"
                        , pressedKeys = newKeys
                      }
                    , (platoJobPoke model.urb
                        { id = model.activeProgram
                        , typ = "compile"
                        , src = Editor.getContent "editor" model.editor
                        }
                      )
                    )
                else
                    ( { model | pressedKeys = Keyboard.update kmsg newKeys }
                    , Cmd.none
                    )

        DragMsg dragmsg ->
            ( { model
                | splitPane = SplitPane.update dragmsg model.splitPane
              }
            , Cmd.none
            )

        Editor editmsg ->
            let
                ( newEditor, cmd ) =
                    Editor.update editmsg model.editor

                newModel =
                    { model | editor = newEditor }
            in
                case editmsg of
                    -- Lock terminal upon creation
                    Editor.Spawned "terminal" ->
                        ( newModel
                        , Cmd.batch
                            [ cmd
                            , EditorPort.editorSend <|
                                Editor.Lock "terminal"
                            ]
                        )

                    -- Create default session for editor
                    Editor.Spawned "editor" ->
                        ( newModel
                        , Cmd.batch
                            [ cmd
                            , EditorPort.editorSend <|
                                Editor.NewSession "editor" "<vacuum>" ""
                            ]
                        )

                    -- We have just created <vacuum> session, switch to it
                    Editor.SessionCreated "editor" "<vacuum>" ->
                        ( newModel
                        , Cmd.batch [ cmd, EditorPort.editorSend <| Editor.ChangeSession "editor" "<vacuum>" ]
                        )

                    -- Anything
                    _ ->
                        ( newModel, cmd )

        RunProgram ->
            ( model, Cmd.none )

        RunClicked ->
            ( { model
                | programs = (setActiveProgramStage model JobParse)
                , status = "Compiling"
              }
            , (platoJobPoke model.urb
                { id = model.activeProgram
                , typ = "compile"
                , src = Editor.getContent "editor" model.editor
                }
              )
            )

        SetStatus id ->
            ( model, Cmd.none )

        WindowResize ( w, h ) ->
            ( { model | windowSize = { width = w, height = h } }, Cmd.none )

        ViewportInfo viewport ->
            ( { model
                | windowSize =
                    { width = Basics.round viewport.viewport.width
                    , height = Basics.round viewport.viewport.height
                    }
              }
            , Cmd.none
            )

        ---- Draggable Pane
        --SplitPaneMsg msg ->
        --let
        --( newSplitPane, paneCmd ) =
        --SplitPane.update msg model.splitPane
        --cmds =
        --case msg of
        --SplitPane.Release _ ->
        --[ EditorPort.editorSend <| Editor.Resize "editor"
        --, EditorPort.editorSend <| Editor.Resize "terminal"
        --]
        --_ ->
        --[]
        --in
        --( { model | splitPane = newSplitPane }
        --, Cmd.batch
        --(paneCmd :: cmds)
        --)
        -- Urbit connector
        Urb urbmsg ->
            let
                ( newUrb, urbCmd ) =
                    Urb.update urbmsg model.urb

                newModel =
                    { model | urb = newUrb, status = "Ok" }
            in
                -- Handle errors
                if (String.length <| Urb.getErrorDesc model.urb) > 0 then
                    ( { newModel | status = Urb.getErrorDesc model.urb }
                    , urbCmd
                    )
                else
                -- If not polling, subscribe
                if
                    not newUrb.isPolling
                then
                    if newUrb.connStatus == Urb.Connected then
                        ( { newModel | status = "Subscribing" }
                        , Cmd.batch [ urbCmd, Poke.Plato.subs newUrb Urb.Conn.Subscribe ]
                        )
                    else
                        ( { newModel | status = "Awaiting authorization" }
                        , urbCmd
                        )
                    -- Already polling, handle incoming data
                else
                    case urbmsg of
                        Urb.PacketResponse (Urb.Conn.Packet (Just (Ok packet))) ->
                            case packet.data of
                                PollJob job ->
                                    let
                                        annotationCmd =
                                            case job.error of
                                                Just err ->
                                                    EditorPort.editorSend <|
                                                        Editor.Annotate "editor" <|
                                                            Poke.Plato.annotFromJobError err

                                                Nothing ->
                                                    EditorPort.editorSend <|
                                                        Editor.ClearAnnotation "editor"

                                        markerCmd =
                                            case job.error of
                                                Just err ->
                                                    EditorPort.editorSend <|
                                                        Editor.ActivateErrorMarker "editor"
                                                            err.reg.start
                                                            err.reg.end

                                                Nothing ->
                                                    EditorPort.editorSend <|
                                                        Editor.ClearErrorMarker "editor"

                                        display =
                                            case job.error of
                                                Just err ->
                                                    getErrorHelp err.kind err.hint

                                                Nothing ->
                                                    job.result
                                    in
                                        ( { newModel | status = "Ok" }
                                        , Cmd.batch
                                            [ EditorPort.editorSend <|
                                                (Editor.SetContent "terminal"
                                                    display
                                                )
                                            , annotationCmd
                                            , markerCmd
                                            , urbCmd
                                            ]
                                        )

                        _ ->
                            ( newModel, urbCmd )
