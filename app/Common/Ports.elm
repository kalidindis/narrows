port module Common.Ports exposing (..)

import Json.Decode
import Common.Models exposing (FullCharacter)


type alias RenderTextInfo =
    { elemId : String
    , text : Json.Decode.Value
    , proseMirrorType : String
    }


type alias InitEditorInfo =
    { elemId : String
    , narrationId : Int
    , narrationImages : List String
    , chapterParticipants : List FullCharacter
    , text : Json.Decode.Value
    , editorType : String
    , updatePortName : String
    }


type alias NarrationMediaInfo =
    { audioElemId : String
    }


port renderText : RenderTextInfo -> Cmd msg


port initEditor : InitEditorInfo -> Cmd msg


port startNarration : NarrationMediaInfo -> Cmd msg


port playPauseNarrationMusic : NarrationMediaInfo -> Cmd msg


port flashElement : String -> Cmd msg


port pageScrollListener : (Int -> msg) -> Sub msg


port markNarrationAsStarted : (Int -> msg) -> Sub msg
