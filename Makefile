
setup:
	mkdir node_modules
	npm install coffee-script

watch:
	./node_modules/coffee-script/bin/coffee -w -c granger.coffee

test:
	./tests/lib/start-server.sh
	buster-test
	./tests/lib/kill-server.sh buster-server && ./tests/lib/kill-server.sh phantom


