buster.spec.expose() # Make some functions global

element = document.createElement 'input'
document.documentElement.appendChild element

describe 'Granger Core', () ->
  @granger = new Granger(element)

  it "should be defined", () ->
    expect(this.granger).toBeDefined()

