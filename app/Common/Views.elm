module Common.Views exposing (..)

import String
import Json.Decode
import Html exposing (Html, h2, div, nav, textarea, button, span, ul, li, img, a, em, strong, text)
import Html.Attributes exposing (class, rows, value, href, src, title)
import Html.Events exposing (defaultOptions, onWithOptions, onClick, onInput)
import Common.Models exposing (MessageThread, Message, Banner, ReplyInformation, Breadcrumb, ChapterOverview, Narration, NarrationOverview, NarrationStatus(..), narrationStatusString)


onPreventDefaultClick : msg -> Html.Attribute msg
onPreventDefaultClick message =
  onWithOptions
    "click"
    { defaultOptions | preventDefault = True }
    (Json.Decode.succeed message)


onStopPropagationClick : msg -> Html.Attribute msg
onStopPropagationClick message =
  onWithOptions
    "click"
    { defaultOptions | stopPropagation = True }
    (Json.Decode.succeed message)


messageView : Message -> Html msg
messageView message =
  div [ class "message" ]
    [ strong []
        [ text (case message.sender of
                  Just sender -> sender.name
                  Nothing -> "Narrator")
        ]
    , text ": "
    , span [ class (case message.sender of
                      Just sender -> ""
                      Nothing -> "narrator")
           ]
        [ text message.body ]
    ]


threadView : Maybe Int -> msg -> (String -> msg) -> msg -> msg -> Maybe ReplyInformation -> MessageThread -> Html msg
threadView maybeCharacterId showReplyMessage updateReplyMessage sendReplyMessage closeReplyMessage maybeReply thread =
  let
    participants =
      List.map
        (\c -> c.name)
        (case maybeCharacterId of
          Just characterId ->
            (List.filter
              (\c -> c.id /= characterId)
              thread.participants
            )

          Nothing ->
            thread.participants
        )

    participantString =
      String.join ", " participants

    participantStringEnd =
      case maybeCharacterId of
        Nothing ->
          if List.length participants > 1 then
            ", and you"
          else
            " and you"

        Just _ ->
          if List.length participants > 0 then
            ", the narrator, and you"
          else
            "the narrator and you"

    participantsDiv =
      div [ class "thread-participants" ]
        [ text ("Between " ++ participantString ++ participantStringEnd) ]

    replyButtonDiv =
      div [ class "btn-bar" ]
        [ button [ class "btn btn-small"
                 , onClick showReplyMessage
                 ]
            [ text "Reply" ]
        ]

    replyBoxDiv =
      case maybeReply of
        Just reply ->
          if reply.recipients == thread.participants then
            div []
              [ textarea [ rows 4
                         , value reply.body
                         , onInput updateReplyMessage
                         ]
                  [ text reply.body ]
              , div [ class "btn-bar" ]
                  [ button
                    [ class "btn btn-default btn-small"
                    , onClick sendReplyMessage
                    ]
                    [ text "Send" ]
                  , button
                    [ class "btn btn-small"
                    , onClick closeReplyMessage
                    ]
                    [ text "Close" ]
                  ]
              ]
          else
            replyButtonDiv

        Nothing ->
          replyButtonDiv
  in
    li []
      (List.concat
        [ [ participantsDiv ]
        , List.map messageView thread.messages
        , [ replyBoxDiv ]
        ])


loadingView : Maybe Banner -> Html msg
loadingView maybeBanner =
  div []
    [ bannerView maybeBanner
    , text "Loading…"
    ]


bannerView : Maybe Banner -> Html msg
bannerView maybeBanner =
  case maybeBanner of
    Just banner ->
      div [ class <| "banner banner-" ++ banner.type_ ]
        [ text banner.text ]

    Nothing ->
      text ""


linkTo : (String -> msg) -> String -> List (Html.Attribute msg)
linkTo message url =
  [ href url
  , onPreventDefaultClick (message url)
  ]


breadcrumbView : (String -> msg) -> Breadcrumb -> Html msg
breadcrumbView messageConstructor link =
  a (linkTo messageConstructor link.url)
    [ text link.title ]


breadcrumbNavView : (String -> msg) -> List Breadcrumb -> Html msg -> Html msg
breadcrumbNavView messageConstructor links pageTitle =
  let
    parts =
      List.concat
        [ (List.map (breadcrumbView messageConstructor) links)
        , [ pageTitle ]
        ]
  in
    nav [ class "breadcrumbs" ]
      (List.intersperse
        (text " ⇢ ")
        parts)


unpublishedChapterView : (String -> msg) -> Narration -> ChapterOverview -> Html msg
unpublishedChapterView navigationMessage narration chapterOverview =
  let
    numberChapterParticipants = List.length chapterOverview.reactions
    numberNarrationCharacters = List.length narration.characters
  in
    li []
      [ a (linkTo
             navigationMessage
             ("/chapters/" ++ (toString chapterOverview.id) ++ "/edit"))
          [ text chapterOverview.title
          ]
      , text " — "
      , em [] [ text "Draft" ]
      , if numberNarrationCharacters /= numberChapterParticipants then
          text (" — only " ++ (toString numberChapterParticipants) ++
                " participants")
        else
          text ""
      ]


publishedChapterView : (String -> msg) -> Narration -> ChapterOverview -> Html msg
publishedChapterView navigationMessage narration chapterOverview =
  let
    numberSentReactions = List.length <|
                          List.filter
                            (\r -> case r.text of
                                     Nothing -> False
                                     _ -> True)
                            chapterOverview.reactions
    numberChapterParticipants = List.length chapterOverview.reactions
    numberNarrationCharacters = List.length narration.characters
    participantNames =
      String.join ", " <|
        List.map
          (\r -> r.character.name)
          chapterOverview.reactions
  in
    li []
      [ a (linkTo
             navigationMessage
             ("/chapters/" ++ (toString chapterOverview.id)))
          [ text chapterOverview.title ]
      , if numberSentReactions /= numberChapterParticipants then
          text (" — "
                ++ (toString <| numberChapterParticipants - numberSentReactions)
                ++ " reaction(s) pending")
        else
          text ""
      , if numberNarrationCharacters /= numberChapterParticipants then
          span [ title <| "Only for " ++ participantNames ]
            [ text " — "
            , img [ src "/img/character.png" ] []
            , text <| toString numberChapterParticipants
            ]
        else
          text ""
      , if chapterOverview.numberMessages > 0 then
          span []
            [ text " — "
            , img [ src "/img/envelope.png" ] []
            , text <| toString chapterOverview.numberMessages
            ]
        else
          text ""
      ]


chapterOverviewView : (String -> msg) -> Narration -> ChapterOverview -> Html msg
chapterOverviewView navigationMessage narration chapterOverview =
  case chapterOverview.published of
    Just published ->
      publishedChapterView navigationMessage narration chapterOverview
    Nothing ->
      unpublishedChapterView navigationMessage narration chapterOverview


narrationOverviewView : (String -> msg) -> NarrationOverview -> List (Html msg)
narrationOverviewView navigationMessage narrationOverview =
  (List.map
     (chapterOverviewView navigationMessage narrationOverview.narration)
     narrationOverview.chapters)


compactNarrationView : (String -> msg) -> NarrationOverview -> Html msg
compactNarrationView navigationMessage overview =
  let
    (ribbon, buttonBar) =
      case overview.narration.status of
        Active ->
          ( text ""
          , button [ class "btn btn-add"
                   , onClick (navigationMessage <| "/narrations/" ++ (toString overview.narration.id) ++ "/new")
                   ]
              [ text "New chapter" ]
          )
        _ ->
          ( div [ class "corner-ribbon top-right" ]
              [ text <| narrationStatusString overview.narration.status ]
          , text ""
          )
  in
    div [ class "narration-container" ]
      [ ribbon
      , div [ class "narration-header" ]
          [ h2 []
            [ a
                (linkTo
                  navigationMessage
                  ("/narrations/" ++ (toString overview.narration.id))
                )
                [ text overview.narration.title ]
            ]
          , buttonBar
          ]
      , ul [ class "chapter-list" ] <|
          narrationOverviewView navigationMessage overview
      ]
