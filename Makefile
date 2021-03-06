
SHELL=/usr/bin/env bash -O globstar -O extglob

psa := psa \
		.spago/*/*/src/**/*.purs \
		--is-lib=.spago \
		--stash \
		--censor-lib \
		--strict


default: check-format build check-test

install:
	yarn install
	spago install

clean:
	rm -rf dist output node_modules

format:
	for src in `git ls-files '*.nix'` ; do \
		nixfmt $$src; \
	done

	for src in `git ls-files '*.purs'` ; do \
		purty $$src --write; \
	done

	for src in `git ls-files '*.dhall'` ; do \
		dhall format --inplace $$src; \
	done

	prettier --write `git ls-files '*.js' '*.yml' '*.json'`

check-format:
	for src in `git ls-files '*.nix'` ; do \
		nixfmt --check $$src; \
	done

	for src in `git ls-files '*.purs'` ; do \
		ACTUAL="`cat $$src`" ; \
		EXPECTED="`purty $$src`" ; \
		if test "$$ACTUAL" != "$$EXPECTED" ; then \
			echo "$$src not formatted." ; \
			exit 1 ; \
		fi \
	done

	for src in `git ls-files '*.dhall'` ; do \
		cat $$src | dhall format --check ; \
	done

	prettier --check `git ls-files '*.js' '*.yml' '*.json'`

build-src:
	$(psa) src/**/*.purs
	parcel build --public-url "." public/index.html

build-test:
	$(psa) @(test|src)/**/*.purs

build: build-src build-test
	
check-test:
	node -e "require('./output/Test.Main').main()"

check: check-format check-test

dev:
	parcel public/index.html

nix-generate:
	cd src; spago2nix generate
	cd test; spago2nix generate

travis-login:
	travis login --com

travis-encryt-key:
	travis encrypt-file ./deploy_key --add --com