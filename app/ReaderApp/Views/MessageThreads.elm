module ReaderApp.Views.MessageThreads exposing (..)

import String
import Html exposing (Html, div, text, textarea, input, button, ul, li, strong, span, label)
import Html.Attributes exposing (id, class, value, rows, type', checked, disabled)
import Html.Events exposing (onClick, onInput, onCheck)

import ReaderApp.Models exposing (Model, MessageThread, Message, Character)
import ReaderApp.Messages exposing (..)

messageView : Message -> Html Msg
messageView message =
  div [ class "message" ]
    [ strong []
        [ text (case message.sender of
                  Just sender -> sender.name
                  Nothing -> "Narrator") ]
    , text ": "
    , span [ class (case message.sender of
                      Just sender -> ""
                      Nothing -> "narrator") ]
        [ text message.body ]
    ]

threadView : MessageThread -> Int -> Html Msg
threadView thread characterId =
  let
    participants =
      List.map
        (\c -> c.name)
        (List.filter
           (\c -> c.id /= characterId)
           thread.participants)
    participantString = String.join ", " participants
    participantStringEnd = if List.length participants > 0 then
                             ", the narrator, and you"
                           else
                             "the narrator and you"
    participantsDiv =
      div [ class "thread-participants" ]
        [ text ("Between " ++ participantString ++ participantStringEnd) ]
  in
    li []
      (participantsDiv :: List.map messageView thread.messages)

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
