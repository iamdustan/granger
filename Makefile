
setup:
	mkdir -p node_modules
	npm install coffee-script
	npm install buster-coffee
	npm install source-map-support

watch:
	./node_modules/coffee-script/bin/coffee --join ./build/granger.js --watch --compile ./lib/*.coffee

test:
	./tests/lib/start-server.sh
	buster-test
	./tests/lib/kill-server.sh buster-server && ./tests/lib/kill-server.sh phantom

test-moar:
	@./tests/lib/start-server.sh
	@coffee ./tests/lib/browsers.coffee
	@buster-test
	@make kill-test

kill-test:
	./tests/lib/kill-server.sh buster-server && ./tests/lib/kill-server.sh phantom




