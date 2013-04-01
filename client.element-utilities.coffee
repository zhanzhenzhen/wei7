emptyElement = (element) -> element.textContent = ""
showElement = (element) -> element.style.visibility = "visible"
hideElement = (element) -> element.style.visibility = "hidden"
isElementVisible = (element) ->
    if window.getComputedStyle(element).visibility == "hidden" then false else true
getElementTranslates = (element) ->
    transform = element.transform.baseVal
    transform.getItem(i) for i in [0...transform.numberOfItems] \
            when transform.getItem(i).type == SVGTransform.SVG_TRANSFORM_TRANSLATE
# 返回元素的最后一个translate的值，如没有则返回(0,0)
getElementTranslate = (element) ->
    currentTranslates = getElementTranslates(element)
    if currentTranslates.length == 0
        new Point(0, 0)
    else
        matrix = currentTranslates[currentTranslates.length - 1].matrix
        new Point(matrix.e, matrix.f)
# 修改元素的最后一个translate的值，如没有则创建
setElementTranslate = (element, value) ->
    transform = element.transform.baseVal
    currentTranslates = getElementTranslates(element)
    translate =
        if currentTranslates.length == 0
            transform.appendItem(ui.root.createSVGTransform())
            transform.getItem(transform.numberOfItems - 1)
        else
            currentTranslates[currentTranslates.length - 1]
    translate.setTranslate(value.x, value.y)
getElementScales = (element) ->
    transform = element.transform.baseVal
    transform.getItem(i) for i in [0...transform.numberOfItems] \
            when transform.getItem(i).type == SVGTransform.SVG_TRANSFORM_SCALE
# 返回元素的最后一个scale的值，如没有则返回1
getElementScale = (element) ->
    currentScales = getElementScales(element)
    if currentScales.length == 0
        1
    else
        matrix = currentScales[currentScales.length - 1].matrix
        (matrix.a + matrix.d) / 2 # 取平均值纯粹是为了好看
# 修改元素的最后一个scale的值，如没有则创建
setElementScale = (element, value) ->
    transform = element.transform.baseVal
    currentScales = getElementScales(element)
    scale =
        if currentScales.length == 0
            transform.appendItem(ui.root.createSVGTransform())
            transform.getItem(transform.numberOfItems - 1)
        else
            currentScales[currentScales.length - 1]
    scale.setScale(value, value)
getElementRotates = (element) ->
    transform = element.transform.baseVal
    transform.getItem(i) for i in [0...transform.numberOfItems] \
            when transform.getItem(i).type == SVGTransform.SVG_TRANSFORM_ROTATE
# 返回元素的最后一个rotate的值，如没有则返回0
getElementRotate = (element) ->
    currentRotates = getElementRotates(element)
    if currentRotates.length == 0
        0
    else
        currentRotates[currentRotates.length - 1].angle
# 修改元素的最后一个rotate的值，如没有则创建
setElementRotate = (element, value) ->
    transform = element.transform.baseVal
    currentRotates = getElementRotates(element)
    rotate =
        if currentRotates.length == 0
            transform.appendItem(ui.root.createSVGTransform())
            transform.getItem(transform.numberOfItems - 1)
        else
            currentRotates[currentRotates.length - 1]
    rotate.setRotate(value, 0, 0)
isInputInElement = (element, event) ->
    # 仅判断event.target是不够的，因为所有touchmove和touchend的target都和其
    # 对应的touchstart相同，无论手指是否移到了元素的外面。
    if element.contains(event.target) and
            element.contains(document.elementFromPoint(event.clientX, event.clientY))
        true
    else
        false
setElementClickHandler = (element, handler, threshold, noPropagation) ->
    threshold ?= 2000
    noPropagation ?= false
    startTime = null
    if isTouchDevice
        element.addEventListener("touchstart", (event) ->
            if event.touches.length == 1 and isInputInElement(element, event.changedTouches[0])
                startTime = window.performance.now()
            else
                startTime = null
        )
        element.addEventListener("touchmove", (event) ->
            if not (event.touches.length == 1 and isInputInElement(element, event.changedTouches[0]))
                startTime = null
        )
        element.addEventListener("touchend", (event) ->
            if startTime? and event.touches.length == 0 and
                    isInputInElement(element, event.changedTouches[0]) and
                    window.performance.now() - startTime < threshold
                if noPropagation then event.stopPropagation()
                handler(event.changedTouches[0])
            startTime = null
        )
    else
        element.addEventListener("mousedown", (event) ->
            if event.button == 0 and isInputInElement(element, event)
                startTime = window.performance.now()
            else
                startTime = null
        )
        element.addEventListener("mousemove", (event) ->
            if not isInputInElement(element, event)
                startTime = null
        )
        element.addEventListener("mouseup", (event) ->
            if startTime? and event.button == 0 and isInputInElement(element, event) and
                    window.performance.now() - startTime < threshold
                if noPropagation then event.stopPropagation()
                handler(event)
            startTime = null
        )
setElementHoldHandler = (element, handler, threshold) ->
    threshold ?= 800
    timeoutID = null
    setDelay = ->
        timeoutID = window.setTimeout(handler, threshold)
    clearDelay = ->
        window.clearTimeout(timeoutID) if timeoutID?
        timeoutID = null
    if isTouchDevice
        element.addEventListener("touchstart", (event) ->
            clearDelay()
            if event.touches.length == 1 and isInputInElement(element, event.changedTouches[0])
                setDelay()
        )
        element.addEventListener("touchmove", (event) ->
            if not (event.touches.length == 1 and isInputInElement(element, event.changedTouches[0]))
                clearDelay()
        )
        element.addEventListener("touchend", ->
            clearDelay()
        )
    else
        element.addEventListener("mousedown", (event) ->
            clearDelay()
            if event.button == 0 and isInputInElement(element, event)
                setDelay()
        )
        element.addEventListener("mousemove", (event) ->
            if not isInputInElement(element, event)
                clearDelay()
        )
        element.addEventListener("mouseleave", ->
            clearDelay()
        )
        element.addEventListener("mouseup", ->
            clearDelay()
        )
