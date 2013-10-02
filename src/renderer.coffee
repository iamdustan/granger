class Renderer
  constructor: (@granger, startValue) ->
    @options = @granger.options
    @_createElements()
    @_calculateDimensions()
    @_bindEvents()
    start = @pointByValue(startValue)
    @update start.x, start.y
    @granger.element.addEventListener('change', (e) =>
      point = @pointByValue(@granger.element.value)
      @draw point.x, point.y
    , false)

  _createElements: () ->
    @granger.element.style.display = 'none'
    @canvas.style.cursor = 'pointer'
    @canvas.style.mozUserSelect =
    @canvas.style.webkitUserSelect =
    @canvas.style.userSelect = 'none'
    @canvas.setAttribute 'data-granger', @granger.element.id

    @granger.element.parentNode.insertBefore @canvas, @granger.element
    @

  _calculateDimensions: () ->
    console.error('Error: _calculateDimensions not available. Renderer should not be instantiated directly')

  _bindEvents: () ->
    isTap = false
    startCoords = lastCoords = undefined
    onResize = (e) =>
      @_calculateDimensions()

    onStart = (e) =>
      isTap = true
      @_calculateDimensions()
      @_toggleSelectable 'none'
      startCoords = @_eventCoordinates(e)
      document.documentElement.addEventListener 'mousemove', onDrag, false
      document.documentElement.addEventListener 'mouseup', onEnd, false
      document.documentElement.addEventListener 'mousecancel', onCancel, false
      document.documentElement.addEventListener 'touchmove', onDrag, false
      document.documentElement.addEventListener 'touchend', onEnd, false
      document.documentElement.addEventListener 'touchcancel', onCancel, false
      return false

    onDrag = (e) =>
      lastCoords = @_eventCoordinates(e)
      result = @getPoint lastCoords.x, lastCoords.y
      if Math.abs(startCoords.x - lastCoords.x) > 10 or Math.abs(startCoords.y - lastCoords.y) > 10
        isTap = false

      @sync result.x, result.y
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
      @_toggleSelectable ''
      document.documentElement.removeEventListener 'mousemove', onDrag
      document.documentElement.removeEventListener 'mouseup', onEnd
      document.documentElement.removeEventListener 'mousecancel', onCancel
      document.documentElement.removeEventListener 'touchmove', onDrag
      document.documentElement.removeEventListener 'touchend', onEnd
      document.documentElement.removeEventListener 'touchcancel', onCancel
      startCoords = lastCoords = undefined

    @canvas.addEventListener 'mousedown', onStart, false
    @canvas.addEventListener 'touchstart', onStart, false
    window.addEventListener 'resize', onResize, false


  sync: (x, y) ->
    # + 1/2 Math.PI === @data.min
    value = @valueByPoint(x, y)
    @granger.sync value
    @

  update: (x, y) ->
    @draw x, y
    @sync x, y
    @

  limit: (value, min = @granger.data.min, max = @granger.data.max) ->
    Math.max(Math.min(value, max), min)

  valueByPoint: (x, y) ->
    if @isSingleVector()
      percentage = x / (@dim.radius * 2)
      percentage = 1 if percentage > 1
      percentage = 0 if percentage < 0
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
    percentage = @limit((value - @granger.data.min) / (@granger.data.max - @granger.data.min), 0, 1)
    if @isSingleVector()
      x = percentage * @dim.width
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

  _offset: () ->
    node = @canvas
    left = node.offsetLeft
    top = node.offsetTop

    while (node = node.offsetParent)
      left += node.offsetLeft
      top += node.offsetTop

    { left, top }

  _eventCoordinates: (e) ->
    if e.type is 'touchmove'
      x = e.touches[0].pageX - @dim.left
      y = e.touches[0].pageY - @dim.top
    else
      x = e.pageX - @dim.left
      y = e.pageY - @dim.top
    { x, y }

  _toggleSelectable: (what)->
    document.body.style['-webkit-user-select'] =
    document.body.style['-moz-user-select'] =
    document.body.style['-ms-user-select'] =
    document.body.style['user-select'] =
    what or ''





