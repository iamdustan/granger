class CanvasRenderer extends Renderer
  _createElements: () ->
    @canvas = document.createElement 'canvas'
    @canvas.setAttribute 'class', 'granger'
    @ctx = @canvas.getContext '2d'

    @canvas.height = @options.height if @options.height
    @canvas.width = @options.width if @options.width

    super()

  _calculateDimensions: () ->
    # left/top offset
    @dim = @_offset()
    @dim.width = @canvas.width
    @dim.height = @canvas.height
    @dim.centerX = @dim.width / 2
    @dim.centerY = @dim.height / 2
    # 6 is the line Width / 2
    @dim.radius = @dim.width / 2 - 6

    @draw @dim.centerX, @dim.centerY
    @

  draw: (x, y) ->
    # reset canvas
    @canvas.width = @canvas.width

    @ctx.strokeStyle = '#cccccc'
    @ctx.lineWidth = 12

    if @isSingleVector()
      @ctx.lineCap = 'round'

      @ctx.beginPath()
      @ctx.moveTo @dim.centerX - @dim.radius, @ctx.lineWidth / 2
      @ctx.lineTo @dim.centerX + @dim.radius, @ctx.lineWidth / 2
      @ctx.stroke()

      @ctx.strokeStyle = '#000000'
      @ctx.lineWidth = 12

      @ctx.beginPath()
      @ctx.arc x, @ctx.lineWidth / 2, @ctx.lineWidth / 2, 0, Math.PI*2, true
      @ctx.fill()
    else
      @ctx.beginPath()
      @ctx.arc @dim.centerX, @dim.centerY, @dim.radius, 0, Math.PI*2, true
      @ctx.stroke()

      @ctx.strokeStyle = '#000000'
      @ctx.lineWidth = 12

      @ctx.beginPath()
      @ctx.arc x, y, @ctx.lineWidth / 2, 0, Math.PI*2, true
      @ctx.fill()

