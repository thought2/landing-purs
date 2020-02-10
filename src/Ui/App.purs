module Ui.App where

import Prelude
import Data.Maybe (Maybe)
import Data.String as String
import Halogen (ClassName(..))
import Halogen as H
import Halogen.HTML (HTML)
import Halogen.HTML as HH
import Halogen.HTML.Properties (class_)
import Halogen.HTML.Properties as HP

type Work
  = { name :: String
    , description :: Maybe String
    , tags :: Array String
    , repo :: Maybe String
    , url :: String
    }

data Query a
  = Query a

type State
  = Input

type Input
  = Array Work

type Output
  = Unit

type Slots
  = Unit

type Action
  = Unit

type Component
  = forall query output m. H.Component HTML query Input output m

type Html
  = forall action slots m. HH.ComponentHTML action slots m

component :: Component
component =
  H.mkComponent
    { initialState: identity
    , render
    , eval: H.mkEval $ H.defaultEval
    }

render :: State -> Html
render works =
  HH.div [ class_ $ ClassName "root" ]
    [ renderHeader
    , HH.div_ (map renderWork works)
    , HH.hr_
    , renderFooter
    ]

renderWork :: Work -> Html
renderWork { name, url, tags } =
  HH.div [ class_ $ ClassName "work" ]
    [ HH.div_
        [ HH.a
            [ HP.href url ]
            [ HH.text name ]
        ]
    , HH.span [ class_ $ ClassName "details" ]
        [ HH.text $ String.joinWith ", " tags ]
    ]

renderHeader :: Html
renderHeader =
  HH.h3_
    [ HH.text "Works"
    ]

renderFooter :: Html
renderFooter =
  HH.div_
    [ HH.span_
        [ HH.text "by "
        , HH.a
            [ HP.href "mailto:me@thought2.de" ]
            [ HH.text "Michael Bock" ]
        ]
    ]
