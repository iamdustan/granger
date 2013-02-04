/*jshint asi:true*/
var exec = require('child_process').exec, firefox, chrome, opera, safari

firefox = exec('open -a /Applications/Firefox.app/ -g http://localhost:1111/capture')
chrome = exec('open -a "/Applications/Google Chrome.app/" http://localhost:1111/capture -g')
opera = exec('open -a /Applications/Opera.app http://localhost:1111/capture -g')
safari = exec('open -a /Applications/Safari.app http://localhost:1111/capture -g')

function kill(process) {
  console.log('Killing the slave', process.pid)
  exec('kill -9' + process.pid)
}

exec('sleep 10', function () {
  kill(firefox)
  kill(chrome)
  kill(opera)
  kill(safari)
})

