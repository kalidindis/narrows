module NarratorApp.Api.Json exposing (..)

import Json.Decode as Json exposing (..)
import Json.Encode

import NarratorApp.Models exposing (Chapter, Character, Narration, FileSet)

parseCharacter : Json.Decoder Character
parseCharacter =
  Json.object3 Character ("id" := int) ("name" := string) ("token" := string)

parseChapter : Json.Decoder Chapter
parseChapter =
  Json.object8 Chapter
    ("id" := int)
    ("narrationId" := int)
    ("title" := string)
    ("audio" := string)
    ("backgroundImage" := string)
    ("text" := Json.value)
    ("participants" := list parseCharacter)
    (maybe ("published" := string))

parseFileSet : Json.Decoder FileSet
parseFileSet =
  Json.object3 FileSet
    ("audio" := list string)
    ("backgroundImages" := list string)
    ("images" := list string)

parseNarration : Json.Decoder Narration
parseNarration =
  Json.object6 Narration
    ("id" := int)
    ("title" := string)
    ("characters" := list parseCharacter)
    (maybe ("defaultAudio" := string))
    (maybe ("defaultBackgroundImage" := string))
    ("files" := parseFileSet)

encodeCharacter : Character -> String
encodeCharacter character =
  (Json.Encode.encode
     0
     (Json.Encode.object [ ("id", Json.Encode.int character.id)
                         , ("name", Json.Encode.string character.name)
                         , ("token", Json.Encode.string character.token)
                         ]))

encodeChapter : Chapter -> String
encodeChapter chapter =
  (Json.Encode.encode
     0
     (Json.Encode.object [ ("title", Json.Encode.string chapter.title)
                         -- TODO: text cannot be taken from
                         -- chapter.text, that's the initial
                         -- one. So either apply the changes there
                         -- somehow (ideal), or fetch the current
                         -- value before saving (sucks, but hey)
                         , ("text", chapter.text)
                         ]))
