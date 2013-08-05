class Renderer
  constructor: (@granger, startValue) ->
    @options = @granger.options
    @_createElements()
    @_calculateDimensions()
    @_bindEvents()
    start = @pointByValue(startValue)
    @update start.x, start.y
    @granger.element.addEventListener('change', (e) =>
      console.log('changed', @granger.element.value)
      point = @pointByValue(@granger.element.value)
      @draw point.x, point.y
    , false)

  _createElements: () ->
    @granger.element.style.display = 'none'
    @canvas.style.cursor = 'pointer'
    @canvas.style.mozUserSelect = 'none'
    @canvas.style.webkitUserSelect = 'none'

    @granger.element.parentNode.insertBefore @canvas, @granger.element
    @

  _calculateDimensions: () ->
    console.error('Error: _calculateDimensions not available. Renderer should not be instantiated directly')

  _bindEvents: () ->
    isTap = false
    startCoords = undefined
    lastCoords = undefined

    onStart = (e) =>
      isTap = true
      startCoords = @_eventCoordinates(e)
      @canvas.addEventListener 'mousemove', onDrag, false
      @canvas.addEventListener 'mouseup', onEnd, false
      @canvas.addEventListener 'mousecancel', onCancel, false
      @canvas.addEventListener 'touchmove', onDrag, false
      @canvas.addEventListener 'touchend', onEnd, false
      @canvas.addEventListener 'touchcancel', onCancel, false
      document.documentElement.addEventListener 'mouseup', onEnd, false
      document.documentElement.addEventListener 'touchend', onEnd, false
      return false

    onDrag = (e) =>
      # TODO: handle this state better. perhaps by using pageX to element offsetX
      return if e.target != @canvas
      lastCoords = @_eventCoordinates(e)
      result = @getPoint lastCoords.x, lastCoords.y
      if Math.abs(startCoords.x - lastCoords.x) > 10 or Math.abs(startCoords.y - lastCoords.y) > 10
        isTap = false

      @sync result.x, result.y
      @draw result.x, result.y
      e.preventDefault()
      return false

    onEnd = (e) =>
      if isTap
        coords = @_eventCoordinates(e)
        result = @getPoint coords.x, coords.y
        @sync result.x, result.y
        @draw result.x, result.y

      onCancel()
      return false

    onCancel = (e) =>
      @canvas.removeEventListener 'mousemove', onDrag
      @canvas.removeEventListener 'mouseup', onEnd
      @canvas.removeEventListener 'mousecancel', onCancel
      @canvas.removeEventListener 'touchmove', onDrag
      @canvas.removeEventListener 'touchend', onEnd
      @canvas.removeEventListener 'touchcancel', onCancel
      document.documentElement.removeEventListener 'mouseup', onEnd
      document.documentElement.removeEventListener 'touchend', onEnd
      startCoords = lastCoords = undefined

    @canvas.addEventListener 'mousedown', onStart, false
    @canvas.addEventListener 'touchstart', onStart, false

  sync: (x, y) ->
    # + 1/2 Math.PI === @data.min
    value = @valueByPoint(x, y)
    @granger.sync value
    @

  update: (x, y) ->
    @draw x, y
    @sync x, y
    @

  limit: (value) ->
    Math.max(Math.min(value, @granger.data.max), @granger.data.min)

  valueByPoint: (x, y) ->
    if @isSingleVector
      percentage = x / (@dim.radius * 2)
    else
      abs = @pointByAngle x, y
      offset = - Math.PI / 2
      radians = Math.atan2(@dim.centerY - abs.y, @dim.centerX - abs.x)
      if radians < Math.PI / 2
        radians = Math.PI * 2 + radians

      percentage = (radians + offset) / (Math.PI * 2)
      #(@granger.data.min / percentage)

    return @limit(percentage * (@granger.data.max - @granger.data.min) + @granger.data.min)

  pointByValue: (value) ->
    percentage = (value - @granger.data.min) / (@granger.data.max - @granger.data.min)
    if @isSingleVector
      x = percentage * @dim.width + @dim.offset / 2
      y = 0
    else
      radians = (percentage * 2 + 0.5) * Math.PI
      x = -1 * @dim.radius * Math.cos(radians) + @dim.centerX
      y = -1 * @dim.radius * Math.sin(radians) + @dim.centerY

    return { x, y }

  pointByAngle: (x, y) ->
    radians = Math.atan2(@dim.centerY - y, @dim.centerX - x)
    x = -1 * @dim.radius * Math.cos(radians) + @dim.centerX
    y = -1 * @dim.radius * Math.sin(radians) + @dim.centerY
    return { x, y }

  pointByLimit: (x, y) ->
    if @isSingleVector()
      return { x, y }

    dx = x - @dim.centerX
    dy = y - @dim.centerY
    distanceSquared = (dx * dx) + (dy * dy)

    if distanceSquared <= @dim.radius * @dim.radius
      return { x, y }

    distance = Math.sqrt(distanceSquared)
    ratio = @dim.radius / distance
    x = dx * ratio + @dim.centerX
    y = dy * ratio + @dim.centerY
    return { x, y }

  getPoint: (x, y) ->
    return @pointByLimit x, y if @options.freeBounds or @isSingleVector()
    @pointByAngle x, y

  isSingleVector: () ->
    /^(x|y)/.test @options.type

  _eventOffset: (e) ->
    x = y = 0
    return { x, y } unless e.offsetParent

    node = @canvas
    while (node = node.offsetParent)
      x += node.offsetLeft
      y += node.offsetTop

    return { x, y }

  _eventCoordinates: (e) ->
    offset = @_eventOffset(e)
    if e.type is 'touchmove'
      x = e.touches[0].pageX - offset.x
      y = e.touches[0].pageY - offset.y
    else
      x = e.layerX - offset.x
      y = e.layerY - offset.y
    { x, y }




