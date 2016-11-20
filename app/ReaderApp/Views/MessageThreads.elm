module ReaderApp.Views.MessageThreads exposing (..)

import Html exposing (Html, div, text, textarea, input, button, ul, li, strong, span, label)
import Html.Attributes exposing (id, class, value, rows, type', checked, disabled)
import Html.Events exposing (onClick, onInput, onCheck)

import Common.Views exposing (threadView)

import ReaderApp.Models exposing (Model, Character)
import ReaderApp.Messages exposing (..)

recipientView : List Int -> Character -> Html Msg
recipientView currentRecipients character =
  label []
    [ input [ type' "checkbox"
            , value (toString character.id)
            , checked (List.any (\r -> r == character.id) currentRecipients)
            , onCheck (UpdateNewMessageRecipient character.id)
            ]
        []
    , text character.name
    ]

recipientListView : List Character -> List Int -> Html Msg
recipientListView possibleRecipients currentRecipients =
  div [ class "recipients" ]
    ([ label [] [ text "Recipients:" ]
     , input [ type' "checkbox", checked True, disabled True ] []
     , text "Narrator"
     ] ++ List.map (recipientView currentRecipients) possibleRecipients)

listView : Model -> Html Msg
listView model =
  let
    character = case model.chapter of
                  Just chapter -> chapter.character
                  Nothing -> { id = 0, name = "", token = "", notes = Nothing }
    otherParticipants = case model.chapter of
                          Just chapter ->
                            List.filter
                              (\p -> p.id /= character.id)
                              chapter.participants
                          Nothing ->
                            []
  in
    div []
      [ ul [ class "message-list" ]
          (case model.messageThreads of
             Just threads ->
               List.map
                 (\mt -> threadView mt character.id)
                 threads
             Nothing ->
               [])
      , div [ class "new-message" ]
        [ textarea [ rows 2
                   , onInput UpdateNewMessageText
                   , value model.newMessageText
                   ]
            [ text model.newMessageText ]
        , recipientListView otherParticipants model.newMessageRecipients
        , div [ class "btn-bar" ]
            [ button [ class "btn"
                    , onClick SendMessage
                    ]
                [ text "Send" ]
            ]
        ]
      ]
