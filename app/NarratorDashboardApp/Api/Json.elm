module NarratorDashboardApp.Api.Json exposing (..)

import Json.Decode as Json exposing (..)
import Common.Api.Json exposing (parseReaction, parseNarrationOverview)
import Common.Models exposing (NarrationOverview, ChapterOverview)
import NarratorDashboardApp.Models exposing (NarratorOverview)


parseNarratorOverview : Json.Decoder NarratorOverview
parseNarratorOverview =
    Json.map NarratorOverview
        (field "narrations" <| list parseNarrationOverview)
