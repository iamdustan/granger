/*jshint asi:true*/
/*global buster, describe, it, expect,
    Granger */
buster.spec.expose(); // Make some functions global

var element = document.createElement('input')
document.documentElement.appendChild(element)

describe('Granger Core', function () {
  this.granger = new Granger(element)

  it("should be defined", function () {
    expect(this.granger).toBeDefined()
  })

})

