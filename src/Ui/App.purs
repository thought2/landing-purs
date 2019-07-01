module Ui.App where

import Prelude

import Data.Maybe (Maybe(Just))
import Data.Symbol (class IsSymbol, SProxy)
import Halogen as H
import Halogen.Data.Slot (Slot)
import Halogen.HTML (HTML(..))
import Halogen.HTML as HH
import Halogen.HTML.Properties as HP
import Prim.Row as Row



type Work =
  { name :: String
  , description :: Maybe String
  , language :: Maybe String
  , repo :: Maybe String
  , url :: String
  }


data Query a = Query a
type State = Input
type Input = Array Work
type Output = Unit
type Slots = Unit
type Action = Unit
type Component = forall query input output m. H.Component HTML query Input output m
type Html = forall action slots m. HH.ComponentHTML action slots m

component :: Component
component =
  H.mkComponent
    { initialState : identity
    , render
    , eval : H.mkEval $ H.defaultEval
    }

render :: State -> Html
render works =
  HH.div_
    [ renderHeader
    , HH.div_ (map renderWork works)
    , HH.hr_
    , renderFooter
    ]

renderWork :: Work -> Html
renderWork { name, url } =
  HH.div_
    [ HH.a
      [ HP.href url ]
      [ HH.text name ]
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
