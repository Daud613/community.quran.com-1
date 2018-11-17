class Utility.ImageZoomer
  constructor: (imgUrl) ->
    @zoomVal=0;
    @canvas = document.getElementsByTagName('canvas')[0]
    @image = new Image
    @ctx = @canvas.getContext('2d')
    @image.src = imgUrl
    @lastX = @canvas.width / 2
    @lastY = @canvas.height / 2

    @trackTransforms @ctx
    @redraw()
    @bindEvents()
    return this

  changeImage: (newUrl) =>
    @image.src = newUrl
    @redraw()
  
  transform: (x, y) =>
    @lastX = x
    @lastY = y
    
  savePosition: (x,y)=>
    $(".pos-x").val(x)
    $(".pos-y").val(y)
    
  zoom: (clicks) =>
    @zoomVal += clicks
    $(".zoom").val(@zoomVal)

    scaleFactor = 1.1
    pt = @ctx.transformedPoint(@lastX, @lastY)
    @ctx.translate pt.x, pt.y
    factor = scaleFactor ** clicks
    @ctx.scale factor, factor
    @ctx.translate -pt.x, -pt.y
    @redraw()
    return

  handleScroll: (evt) =>
    delta = if evt.wheelDelta then evt.wheelDelta / 40 else if evt.detail then -evt.detail else 0
    if delta
      @zoom delta
    evt.preventDefault() and false
    
  bindEvents: =>
    dragStart = undefined
    dragged = undefined
    
    @canvas.addEventListener 'DOMMouseScroll', @handleScroll, false
    @canvas.addEventListener 'mousewheel', @handleScroll, false
    that = @
    @canvas.addEventListener 'mousedown', ((evt) ->
      document.body.style.mozUserSelect = document.body.style.webkitUserSelect = document.body.style.userSelect = 'none'
      that.lastX = evt.offsetX or evt.pageX - (that.canvas.offsetLeft)
      that.lastY = evt.offsetY or evt.pageY - (that.canvas.offsetTop)
      that.savePosition(that.lastX, that.lastY)
      dragStart = that.ctx.transformedPoint(that.lastX, that.lastY)
      dragged = false
      return
    ), false
    
    @canvas.addEventListener 'mousemove', ((evt) ->
      lastX = evt.offsetX or evt.pageX - (that.canvas.offsetLeft)
      lastY = evt.offsetY or evt.pageY - (that.canvas.offsetTop)
      dragged = true
      if dragStart
        pt = that.ctx.transformedPoint(lastX, lastY)
        that.ctx.translate pt.x - (dragStart.x), pt.y - (dragStart.y)
        that.redraw()
      return
    ), false
    
    @canvas.addEventListener 'mouseup', ((evt) ->
      document.body.style.mozUserSelect = document.body.style.webkitUserSelect = document.body.style.userSelect = 'auto'
      dragStart = null
      if !dragged
        that.zoom if evt.shiftKey then -1 else 1
      return
    ), false
  
    
  redraw: =>
    # Clear the entire canvas
    p1 = @ctx.transformedPoint(0, 0)
    p2 = @ctx.transformedPoint(@canvas.width, @canvas.height)
    @ctx.save()
    @ctx.setTransform 1, 0, 0, 1, 0, 0
    @ctx.clearRect 0, 0, @canvas.width, @canvas.height

    @ctx.restore()
    @ctx.drawImage @image, 0, 0
    return
    
  # Adds ctx.getTransform() - returns an SVGMatrix
  # Adds ctx.transformedPoint(x,y) - returns an SVGPoint
  trackTransforms: (ctx) =>
    svg = document.createElementNS('http://www.w3.org/2000/svg', 'svg')
    xform = svg.createSVGMatrix()

    ctx.getTransform = ->
      xform

    savedTransforms = []
    save = ctx.save

    ctx.save = ->
      savedTransforms.push xform.translate(0, 0)
      save.call ctx

    restore = ctx.restore

    ctx.restore = ->
      xform = savedTransforms.pop()
      restore.call ctx

    scale = ctx.scale

    ctx.scale = (sx, sy) ->
      xform = xform.scaleNonUniform(sx, sy)
      scale.call ctx, sx, sy

    rotate = ctx.rotate

    ctx.rotate = (radians) ->
      xform = xform.rotate(radians * 180 / Math.PI)
      rotate.call ctx, radians

    translate = ctx.translate

    ctx.translate = (dx, dy) ->
      xform = xform.translate(dx, dy)
      translate.call ctx, dx, dy

    transform = ctx.transform

    ctx.transform = (a, b, c, d, e, f) ->
      m2 = svg.createSVGMatrix()
      m2.a = a
      m2.b = b
      m2.c = c
      m2.d = d
      m2.e = e
      m2.f = f
      xform = xform.multiply(m2)
      transform.call ctx, a, b, c, d, e, f

    setTransform = ctx.setTransform

    ctx.setTransform = (a, b, c, d, e, f) ->
      xform.a = a
      xform.b = b
      xform.c = c
      xform.d = d
      xform.e = e
      xform.f = f
      setTransform.call ctx, a, b, c, d, e, f

    pt = svg.createSVGPoint()

    ctx.transformedPoint = (x, y) ->
      pt.x = x
      pt.y = y
      pt.matrixTransform xform.inverse()
