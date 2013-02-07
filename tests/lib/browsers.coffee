
exec = require('child_process').exec

launch = (browser) ->
  exec "open -n -g -a /Applications/#{ browser }.app/ http://localhost:1111/capture"

kill = (process) ->
  console.log "Killing the slave #{ process.pid }"
  exec "kill -9 #{ process.pid }"

browsers = ['Firefox', 'Chrome', 'Opera', 'Safari']

launch browser for browser in browsers

exec 'sleep 10', () ->
  kill browser for browser in browsers
  undefined

