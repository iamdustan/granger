
setup:
	mkdir node_modules
	npm install coffee-script

watch:
	./node_modules/coffee-script/bin/coffee --output ./build --watch --compile ./lib/*.coffee

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




