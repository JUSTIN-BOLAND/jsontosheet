port module Accio exposing (..)

import Html exposing (..)
import Html.App as App
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode exposing (Decoder, string)
import Json.Encode
import Task
import Debug
import String
import Regex exposing (..)

main =
  App.program
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }



-- MODEL


type alias Model =
  { url : String
  , response : String
  }


init : (Model, Cmd Msg)
init =
  ( Model "" "", Cmd.none )


-- UPDATE

type Msg
  = Url String
  | GetData
  | FetchSucceed String
  | FetchFail Http.Error
  | Display String

port format : String -> Cmd msg

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Url url ->
      ({ model | url = url }, Cmd.none)

    GetData ->
      (model, getJson model.url)

    FetchSucceed response ->
      (model, format response)

    FetchFail error ->
      ({model | response = toString error}, Cmd.none)

    Display javascriptValue ->
      ({model | response = prettify javascriptValue}, Cmd.none)

prettify : String -> String
prettify = Regex.replace All(Regex.regex ",") (\_ -> ",\n")

-- VIEW


view : Model -> Html Msg
view model =
  div []
    [ input [ type' "text", placeholder "url", onInput Url ] []
    , button [ onClick GetData ] [ text "Get Data"]
    , pre [class "prettyprint"] [ text model.response ]
    ]



-- SUBSCRIPTIONS
port javascriptValues : (String -> msg) -> Sub msg

subscriptions : Model -> Sub Msg
subscriptions model =
  javascriptValues Display



-- HTTP


getJson : String -> Cmd Msg
getJson url =
  Task.perform FetchFail FetchSucceed (Http.getString ("http://localhost:4000/response?url=" ++ url))
  -- Task.perform FetchFail FetchSucceed (Http.getString (url))
