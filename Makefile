bundle: clean
	mkdir dist
	cp -r public/* -t dist
	spago bundle-app --to dist/index.js

clean-all:
	rm -rf dist
	rm -rf output
	rm -rf .spago

clean:
	rm -rf dist

build:
	spago build
