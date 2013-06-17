element = document.createElement 'input'
document.documentElement.appendChild element

describe 'Granger Core', () ->
  beforeEach ()->
    @granger = new Granger(element)
    @renderer = @granger.renderer

  it 'should be defined', () ->
    expect(@renderer).toBeDefined()

  it 'should have a sync method', () ->
    expect(@renderer.sync).toBeDefined()

  it 'should have the appropriate properties', () ->
    expect(@renderer.granger).toBeDefined()
    expect(@renderer.options).toBeDefined()
    expect(@renderer.dim).toBeDefined()

  it 'should have the appropriate methods', () ->
    expect(@renderer._createElements).toBeDefined()
    expect(@renderer._bindEvents).toBeDefined()
    expect(@renderer.sync).toBeDefined()
    expect(@renderer.valueByPoint).toBeDefined()
    expect(@renderer.pointByValue).toBeDefined()
    expect(@renderer.pointByAngle).toBeDefined()
    expect(@renderer.pointByLimit).toBeDefined()
    expect(@renderer.getPoint).toBeDefined()

