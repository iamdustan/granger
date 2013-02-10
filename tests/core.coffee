buster.spec.expose() # Make some functions global

element = document.createElement 'input'
document.documentElement.appendChild element

describe 'Granger Core', () ->
  @granger = new Granger(element)

  it 'should be defined', () ->
    expect(@granger).toBeDefined()

  it 'should have a sync method', () ->
    expect(@granger.sync).toBeDefined()

  it 'should have the appropriate properties', () ->
    expect(@granger.element).toBeDefined()
    expect(@granger.options).toBeDefined()
    expect(@granger.data).toBeDefined()
    expect(@granger.renderer).toBeDefined()

describe 'Granger::sync', () ->
  beforeEach () ->
    @granger = new Granger element

  it 'should update @element based on value', () ->
    @granger.sync(100)
    expect(@granger.element.value).toEqual(100)
    @granger.sync(200)
    expect(@granger.element.value).toEqual(200)
  it 'should emit a DOM change event that propagates', (done) ->
    changeHandler = (e) ->
      expect(true).toEqual(true)
      document.removeEventListener('change', changeHandler, false)
      done()
    document.addEventListener('change', changeHandler, false)
    @granger.sync(50)


