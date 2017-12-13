module Benchmark.Runner.InProgress exposing (Class, styles, view)

import Benchmark.Reporting as Reporting exposing (Report(..))
import Benchmark.Runner.Text as Text
import Benchmark.Status as Status exposing (Status)
import Color
import Element exposing (..)
import Element.Attributes exposing (..)
import Json.Encode as Encode
import Style exposing (..)
import Style.Color as Color
import Style.Font as Font
import Style.Shadow as Shadow
import Style.Sheet as Sheet


view : Report -> Element Class variation msg
view report =
    report
        |> progressBars []
        |> (::) (Text.hero TextClass "Benchmarks Running")
        |> column Unstyled []


progressBars : List String -> Report -> List (Element Class variation msg)
progressBars reversedParents report =
    case report of
        Single name status ->
            [ progressBar (List.reverse reversedParents) name status ]

        Series name statuses ->
            [ text "TODO" ]

        Group name reports ->
            reports
                |> List.map (progressBars (name :: reversedParents))
                |> List.concat


progressBar : List String -> String -> Status -> Element Class variation msg
progressBar parents name status =
    column Unstyled
        [ paddingTop 5 ]
        [ Text.path TextClass parents
        , row Box
            [ paddingXY 10 5, width (px 500) ]
            [ caption name status ]
            |> within [ filledPortion name status ]
        ]


caption : String -> Status -> Element Class variation msg
caption name status =
    el Unstyled
        [ width (px 500) ]
        (text name)


filledPortion : String -> Status -> Element Class variation msg
filledPortion name status =
    if Status.progress status > 0 then
        el Progress
            [ paddingTop 5
            , paddingBottom 5
            , paddingLeft 10
            , clip
            , width
                (status
                    |> Status.progress
                    |> (*) 100
                    |> percent
                )

            -- display as a progressbar for a11y
            , attribute "role" "progressbar"
            , attribute "aria-valuenow"
                (status
                    |> Status.progress
                    |> (*) 100
                    |> floor
                    |> toString
                )
            , attribute "aria-valuemin" "0"
            , attribute "aria-valuemax" "100"
            ]
            (caption name status)
    else
        empty



-- STYLES


type Class
    = Unstyled
    | Path
    | Box
    | Progress
    | TextClass Text.Class


styles : List (Style Class variation)
styles =
    [ style Unstyled []
    , style Box
        [ Color.background (Color.rgb 248 248 248)
        , Shadow.box
            { offset = ( 0, 1 )
            , size = 0
            , blur = 2
            , color = Color.rgba 15 30 45 0.1
            }
        , Font.size 24
        ]
    , style Progress
        [ Color.text (Color.rgb 248 248 248)
        , Color.background (Color.rgb 87 171 226)
        ]
    , Text.styles
        |> Sheet.map TextClass identity
        |> Sheet.merge
    ]