let src = ./src/spago.dhall

let test = ./test/spago.dhall

in  { name =
        "landing-purs-all"
    , dependencies =
        src.dependencies # test.dependencies
    , packages =
        ./packages.dhall
    , sources =
        src.sources # test.dependencies
    }
