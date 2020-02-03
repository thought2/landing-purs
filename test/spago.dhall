{ name =
    "landing-purs-test"
, dependencies =
    (../src/spago.dhall).dependencies # [ "psci-support" ]
, packages =
    ../packages.dhall
, sources =
    [ "src/**/*.purs", "test/**/*.purs" ]
}
