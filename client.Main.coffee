parseElement = (s) -> (new DOMParser()).parseFromString(s, "application/xml").documentElement
codifyElement = (object, elementString) ->
    handle = (element) ->
        id = element.getAttribute("id")
        object[id] = element if id != null
    rootElement = parseElement(elementString)
    handle(rootElement)
    for m in rootElement.getElementsByTagName("*")
        handle(m)
ui = {}
codifyElement(ui, """
    <g id="board" xmlns="http://www.w3.org/2000/svg">
        <rect x="-512" y="-512" width="1024" height="1024" fill="rgb(219,179,119)" />
        <g id="boardLoads">
            <g id="boardGrid" />
            <g id="boardStones" />
            <g id="boardMarks" />
            <g id="boardActiveStoneReminder" opacity="0.5">
                <rect x="-32" y="-32" width="64" height="64" fill="none" stroke="rgb(255,0,0)"
                        stroke-width="5" />
            </g>
        </g>
        <g id="boardDialog" />
    </g>
""")
codifyElement(ui, """
    <radialGradient id="blackStoneGradient" r="0.5" xmlns="http://www.w3.org/2000/svg">
        <stop offset="0" stop-color="rgb(82,82,90)" />
        <stop offset="0.333" stop-color="rgb(74,74,82)" />
        <stop offset="0.667" stop-color="rgb(62,62,70)" />
        <stop offset="1" stop-color="rgb(44,44,52)" />
    </radialGradient>
""")
codifyElement(ui, """
    <radialGradient id="whiteStoneGradient" r="0.5" xmlns="http://www.w3.org/2000/svg">
        <stop offset="0" stop-color="rgb(238,238,246)" />
        <stop offset="0.333" stop-color="rgb(226,226,234)" />
        <stop offset="0.667" stop-color="rgb(206,206,214)" />
        <stop offset="0.834" stop-color="rgb(192,192,200)" />
        <stop offset="1" stop-color="rgb(170,170,178)" />
    </radialGradient>
""")
codifyElement(ui, """
    <symbol id="blackStone" viewBox="-64 -64 128 128" overflow="visible" xmlns="http://www.w3.org/2000/svg">
        <circle r="64" fill="rgb(128,128,136)" fill-opacity="0.625" stroke="rgb(48,48,56)" stroke-width="7" />
        <circle r="56" fill="rgb(48,48,56)" />
    </symbol>
""")
codifyElement(ui, """
    <symbol id="whiteStone" viewBox="-64 -64 128 128" overflow="visible" xmlns="http://www.w3.org/2000/svg">
        <circle r="64" fill="rgb(238,238,246)" stroke="rgb(128,128,136)" stroke-width="7" />
    </symbol>
""")
addSquareButton = (text, position, clickHandler) ->
    element = parseElement("""
        <g transform="translate(#{position.x},#{position.y})" cursor="pointer"
                xmlns="http://www.w3.org/2000/svg">
            <rect x="-52" y="-52" width="104" height="104" rx="8" opacity="0.8"
                    fill="rgb(0,128,255)" stroke="rgb(255,255,255)" stroke-width="3" />
            <text x="0" y="20" fill="rgb(255,255,255)" font-size="56" text-anchor="middle" />
        </g>
    """)
    element.getElementsByTagName("text")[0].textContent = text
    element.addEventListener("click", clickHandler) if clickHandler != null and clickHandler != undefined
    ui.boardDialog.appendChild(element)
    element
emptyElement = (element) -> element.textContent = ""
showElement = (element) -> element.setAttribute("visibility", "visible")
hideElement = (element) -> element.setAttribute("visibility", "hidden")
isElementVisible = (element) ->
    if window.getComputedStyle(element).visibility == "hidden" then false else true
# callback在棋盘“消失”动画后“出现”动画前被调用，它可以包含对新棋盘将要显示的按钮、棋子等的绘画语句
initBoard = (size, callback) ->
    translateToAnimate(
        ui.board, new Point(-ui.root.positionLimit.x - 768, 0),
        null, 0, 500, easeTimingFunction, ->
            ui.board.make(size)
            callback?()
            translateAnimate(ui.board, new Point(ui.root.positionLimit.x + 768, 0), new Point(0, 0),
                    null, 0, 500, easeTimingFunction)
    )
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
class Point
    constructor: (@x, @y) ->
    equal: (p) -> p.x == @x and p.y == @y
    add: (p) -> new Point(@x + p.x, @y + p.y)
    multiply: (n) -> new Point(@x * n, @y * n)
class BoardPointLabels
    constructor: (@boardSize) ->
        @points = (null for i in [0...size * size])
    convertPointToIndex = (point) -> point.y * @boardSize + point.x
    getLabel: (point) -> @points[convertPointToIndex(point)]
    setLabel: (point, label) -> @points[convertPointToIndex(point)] = label
setDebugVariables = ->
    window.wei7debug = {}
    d = window.wei7debug
    d.ui = ui
    d.Point = Point
windowWidth = 0
windowHeight = 0
refreshForResize = ->
    w = window.innerWidth
    h = window.innerHeight
    if w != windowWidth or h != windowHeight
        windowWidth = w
        windowHeight = h
        ui.root.positionLimit = ui.root.convertPointFromScreen(new Point(w, h))
applyHomePage = ->
    ui.board.addWelcomeStones()
    addSquareButton("人", new Point(-320, 224), -> initBoard(19, ->
        addSquareButton("回", new Point(0, 0), -> initBoard(19, applyHomePage))
    ))
    addSquareButton("机", new Point(-160, 224), -> initBoard(19))
    addSquareButton("学", new Point(0, 224), -> initBoard(19))
    addSquareButton("谱", new Point(160, 224), -> initBoard(19))
    addSquareButton("?", new Point(320, 224), undefined)
document.addEventListener("DOMContentLoaded", ->
    svgPoint = (x, y) ->
        p = ui.root.createSVGPoint()
        p.x = x
        p.y = y
        p
    ui.root = document.getElementById("root")
    ui.root.convertPointToScreen = (p) ->
        p1 = svgPoint(p.x, p.y)
        p2 = p1.matrixTransform(ui.root.getScreenCTM())
        new Point(p2.x, p2.y)
    ui.root.convertPointFromScreen = (p) ->
        p1 = svgPoint(p.x, p.y)
        p2 = p1.matrixTransform(ui.root.getScreenCTM().inverse())
        new Point(p2.x, p2.y)
    window.addEventListener("resize", refreshForResize)
    refreshForResize()
    ui.root.appendChild(ui.blackStoneGradient)
    ui.root.appendChild(ui.whiteStoneGradient)
    ui.root.appendChild(ui.blackStone)
    ui.root.appendChild(ui.whiteStone)
    ui.board.marginFactor = 0.728
    ui.board.gridlineWidthFactor = 0.057
    ui.board.borderWidthFactor = 0.133
    ui.board.starRadiusFactor = 0.114
    ui.board.stoneSizeFactor = 0.94
    ui.board.axisValue = (index) -> -ui.board.axisValueLimit + ui.board.margin + index * ui.board.unitLength
    ui.board.mapPoint = (gamePoint) ->
        new Point(ui.board.axisValue(gamePoint.x), ui.board.axisValue(gamePoint.y))
    ui.board.make = (size) ->
        calcUnitLength = (size) -> 1024 / (size - 1 + ui.board.marginFactor * 2)
        emptyElement(ui.boardGrid)
        emptyElement(ui.boardStones)
        emptyElement(ui.boardMarks)
        emptyElement(ui.boardDialog)
        ui.board.setActiveStone(null)
        ui.board.size = size
        ui.board.unitLength = calcUnitLength(19)
        ui.board.actualUnitLength = calcUnitLength(size)
        ui.board.loadsScale = ui.board.actualUnitLength / ui.board.unitLength
        ui.board.axisValueLimit = 512 / ui.board.loadsScale
        ui.boardLoads.setAttribute("transform", "scale(#{ui.board.loadsScale})")
        ui.board.margin = ui.board.unitLength * ui.board.marginFactor
        gridlineWidth = ui.board.unitLength * ui.board.gridlineWidthFactor
        borderWidth = ui.board.unitLength * ui.board.borderWidthFactor
        starRadius = ui.board.unitLength * ui.board.starRadiusFactor
        b = ui.board.axisValueLimit - ui.board.margin
        for i in [0...size]
            n = ui.board.axisValue(i)
            ui.boardGrid.appendChild(parseElement("""
                <line x1="#{-b}" y1="#{n}" x2="#{b}" y2="#{n}"
                        stroke="rgb(146,119,101)" stroke-width="#{gridlineWidth}"
                        xmlns="http://www.w3.org/2000/svg" />
            """))
            ui.boardGrid.appendChild(parseElement("""
                <line x1="#{n}" y1="#{-b}" x2="#{n}" y2="#{b}"
                        stroke="rgb(146,119,101)" stroke-width="#{gridlineWidth}"
                        xmlns="http://www.w3.org/2000/svg" />
            """))
        ui.boardGrid.appendChild(parseElement("""
            <rect x="#{-b}" y="#{-b}" width="#{b*2}" height="#{b*2}"
                    fill="none" stroke="rgb(146,119,101)" stroke-width="#{borderWidth}"
                    xmlns="http://www.w3.org/2000/svg" />
        """))
        drawStar = (point) ->
            p = ui.board.mapPoint(point)
            ui.boardGrid.appendChild(parseElement("""
                <circle r="#{starRadius}" cx="#{p.x}" cy="#{p.y}"
                        fill="rgb(146,119,101)"
                        xmlns="http://www.w3.org/2000/svg" />
            """))
        if size % 2 == 1
            drawStar(new Point((size - 1) / 2, (size - 1) / 2))
            if size > 11
                drawStar(new Point((size - 1) / 2, 3))
                drawStar(new Point(size - 1 - 3, (size - 1) / 2))
                drawStar(new Point((size - 1) / 2, size - 1 - 3))
                drawStar(new Point(3, (size - 1) / 2))
        if size > 9
            drawStar(new Point(3, 3))
            drawStar(new Point(size - 1 - 3, 3))
            drawStar(new Point(3, size - 1 - 3))
            drawStar(new Point(size - 1 - 3, size - 1 - 3))
    ui.board.getStone = (gamePoint) ->
        (m for m in ui.boardStones.childNodes \
                when m.nodeType == Node.ELEMENT_NODE and m.gamePoint.equal(gamePoint))[0]
    ui.board.addStone = (color, gamePoint) ->
        p = ui.board.mapPoint(gamePoint)
        stoneSize = ui.board.unitLength * ui.board.stoneSizeFactor
        symbolID =
            if color == "black"
                "blackStone"
            else if color == "white"
                "whiteStone"
            else fail()
        element = parseElement("""
            <use x="#{p.x - stoneSize / 2}" y="#{p.y - stoneSize / 2}"
                    width="#{stoneSize}" height="#{stoneSize}"
                    xlink:href="##{if color == "black" then "blackStone" else "whiteStone"}"
                    xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" />
        """)
        element.gamePoint = gamePoint
        element.stoneColor = color
        ui.boardStones.appendChild(element)
    ui.board.removeStone = (gamePoint) -> ui.boardStones.removeChild(ui.board.getStone(gamePoint))
    ui.board.setActiveStone = (gamePoint) ->
        if gamePoint == null
            hideElement(ui.boardActiveStoneReminder)
        else
            setElementTranslate(ui.boardActiveStoneReminder, ui.board.mapPoint(gamePoint))
            showElement(ui.boardActiveStoneReminder)
    ui.board.make(19)
    applyHomePage()
    setElementTranslate(ui.board, new Point(ui.root.positionLimit.x + 768, 0))
    ui.root.appendChild(ui.board)
    translateToAnimate(ui.board, new Point(0, 0), null, 750, 2000, elasticTimingFunctionGenerator(30, 600, 5))
)
setDebugVariables()
