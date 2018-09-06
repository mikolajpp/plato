module Poke.Plato exposing (..)

import Urb.Urb
import Urb.Conn
import Urb.Ship
import Json.Encode as E
import Json.Decode as D
import Regex
import Ace as Editor


type alias PlatoProgramPoke =
    { id : Int
    , typ : String
    , src : String
    }


platoJobPoke urb poke =
    Urb.Urb.sendPoke
        urb
        { ship = Urb.Ship.toP urb.ship
        , app = "plato"
        , wire = "/plato-elm"
        , mark = "plato-job"
        , xyro =
            (E.object
                [ ( "id", E.int poke.id )
                , ( "type", E.string poke.typ )
                , ( "src", E.string poke.src )
                ]
            )
        }


subs urb action =
    Urb.Urb.sendSub
        urb
        { -- FIXME: comets work too?
          ship = String.join "-" urb.ship.address
        , app = "plato"
        , mark = "plato-job"
        , wire = "job"
        }
        action


type ErrorType
    = SyntaxError
    | NestFail
    | MintVain
    | MintLost
    | Find
    | FindFork
    | UnknownError


type alias ErrorLoc =
    { row : Int
    , col : Int
    }


type alias ErrorRegion =
    { start : ErrorLoc
    , end : ErrorLoc
    }


type alias JobError =
    { reg : ErrorRegion
    , hint : String
    , kind : ErrorType
    }


defaultJobError =
    { loc = { row = 0, col = 0 }
    , msg = "No Error"
    , kind = SyntaxError
    }


type alias JobPayload =
    { typ : String
    , status : String
    , id : Int
    , result : String
    , error : Maybe JobError
    }


type PollType
    = PollJob JobPayload


codecs : List ( Regex.Regex, D.Decoder PollType )
codecs =
    [ ( Maybe.withDefault Regex.never <|
            Regex.fromString
                "/job"
      , jobPayloadDecoder
      )
    ]


errorLocDecoder : D.Decoder ErrorLoc
errorLocDecoder =
    D.map2 ErrorLoc
        (D.field "row" D.int)
        (D.field "col" D.int)


errorRegDecoder : D.Decoder ErrorRegion
errorRegDecoder =
    D.map2 ErrorRegion
        (D.field "start" errorLocDecoder)
        (D.field "end" errorLocDecoder)


errorTypeDecoder : D.Decoder ErrorType
errorTypeDecoder =
    D.string |> D.andThen errorTypeFromStr


errorTypeFromStr : String -> D.Decoder ErrorType
errorTypeFromStr str =
    case str of
        "syntax-error" ->
            D.succeed SyntaxError

        "nest-fail" ->
            D.succeed NestFail

        "mint-vain" ->
            D.succeed MintVain

        "mint-lost" ->
            D.succeed MintLost

        "find" ->
            D.succeed Find

        "find-fork" ->
            D.succeed FindFork

        _ ->
            D.succeed UnknownError


jobErrorDecoder : D.Decoder JobError
jobErrorDecoder =
    D.map3 JobError
        (D.field "region" errorRegDecoder)
        (D.field "hint" D.string)
        (D.field "error-kind" errorTypeDecoder)


jobPayloadDecoder : D.Decoder PollType
jobPayloadDecoder =
    D.map PollJob <|
        (D.map5 JobPayload
            (D.field "type" D.string)
            (D.field "status" D.string)
            (D.field "id" D.int)
            (D.field "result" D.string)
            (D.field "error" <| D.nullable jobErrorDecoder)
        )


getErrorDesc : ErrorType -> String -> String
getErrorDesc err hint =
    case err of
        SyntaxError ->
            "Syntax Error"

        NestFail ->
            "Nest Fail"

        MintVain ->
            "Mint Vain"

        MintLost ->
            "Mint Lost"

        Find ->
            "Not Found"

        FindFork ->
            "Fork Not Found"

        UnknownError ->
            "Sorry! I have no idea what this means."


getErrorHelp : ErrorType -> String -> String
getErrorHelp err hint =
    case err of
        SyntaxError ->
            "**  Syntax Error  **\nCheck for missing spaces,\nparentheses, numbery syntax, or wrong rune syntax."

        NestFail ->
            "**  Nest Fail  **\nThe compiler expects\ndifferent type here."

        MintVain ->
            "**  Mint Vain  **\nThis code path\nis never reached, remove it."

        MintLost ->
            "**  Mint Lost  **\nThe branching\nis inexhaustive. Consider all cases."

        Find ->
            "**  Not Found  **\nSymbol '" ++ hint ++ "'\nis not found in the current subject."

        FindFork ->
            "**  Fork Not Found  **\nThe fork '" ++ hint ++ "'\nis not found."

        UnknownError ->
            "Sorry! I have no idea what this means."


annotFromJobError : JobError -> Editor.Annotation
annotFromJobError err =
    let
        nRow =
            err.reg.start.row - 1

        nCol =
            err.reg.start.col - 1
    in
        { row = nRow
        , col = nCol
        , text = getErrorDesc err.kind err.hint
        , typ = "error"
        }
