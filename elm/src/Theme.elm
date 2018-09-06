module Theme exposing (..)

import Element exposing (..)
import Element.Font as Font


appBgColor =
    rgba 0.2 0.2 0.2 1.0


appBgColorDark =
    rgba 0.1 0.1 0.1 1.0


appBgColorLight =
    rgba255 12 12 13 0.2


buttonHighlightColor =
    rgba 0.9 0.9 0.9 1.0


identityColor =
    rgba 0.0 0.8 0.0 1.0


appFont =
    Font.family
        [ Font.typeface "Share Tech Mono"
        , Font.monospace
        ]



-- Some common colors


white =
    rgb 1.0 1.0 1.0


grey =
    rgb 0.6 0.6 0.6


yellow =
    rgb255 255 247 20


darkBlue =
    rgb255 1 102 191
