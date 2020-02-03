module Main where

import Prelude
import Effect (Effect)
import Effect.Console (log)
import Data.Maybe (Maybe(..))
import Effect (Effect)
import Halogen.Aff as HA
import Halogen.VDom.Driver (runUI)
import Ui.App as UiApp

works :: Array UiApp.Work
works =
  [ { name: "Lorem Picsum"
    , description: Nothing
    , repo: Nothing
    , language: Just "JavaScript"
    , url: "/lorem-picsum/"
    }
  , { name: "Dust"
    , description: Nothing
    , repo: Nothing
    , language: Just "Elm"
    , url: "http://thought2.canopus.uberspace.de/builds/v4f0d7qdhl16avhjavhf5zfmcf5lp4id-dust/"
    }
  , { name: "Slot Machine"
    , description: Nothing
    , repo: Nothing
    , language: Just "PureScript"
    , url: "http://thought2.canopus.uberspace.de/builds/gfxbsfm10y9b77kz4r4x20apcm1nrhz6-slot-machine/"
    }
  , { name: "2nd Thought"
    , description: Nothing
    , repo: Nothing
    , language: Just "JavaScript"
    , url: "http://thought2.canopus.uberspace.de/2nd_thought/"
    }
  , { name: "Cord Space"
    , description: Nothing
    , repo: Nothing
    , language: Just "JavaScript"
    , url: "http://thought2.canopus.uberspace.de/cord_space/"
    }
  ]

main :: Effect Unit
main =
  HA.runHalogenAff do
    body <- HA.awaitBody
    runUI UiApp.component works body
