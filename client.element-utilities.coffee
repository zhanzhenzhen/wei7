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
