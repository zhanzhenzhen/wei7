ui.board.marginFactor = 0.728
ui.board.gridlineWidthFactor = 0.057
ui.board.borderWidthFactor = 0.133
ui.board.starRadiusFactor = 0.114
ui.board.stoneSizeFactor = 0.94
# callback在棋盘“消失”动画后“出现”动画前被调用，它可以包含对新棋盘将要显示的按钮、棋子等的绘画语句
ui.board.init = (size, callback) ->
    hideElement(ui.info1)
    hideElement(ui.info2)
    translateAnimate(
        ui.board, undefined, new Point(-ui.root.positionLimit.x - 768, 0),
        undefined, 0, 500, easeTimingFunction, ->
            ui.board.make(size)
            callback?()
            translateAnimate(
                ui.board, new Point(ui.root.positionLimit.x + 768, 0), new Point(0, 0),
                undefined, 0, 500, easeTimingFunction, ->
                    showElement(ui.info1)
                    showElement(ui.info2)
            )
    )
ui.board.axisValue = (index) -> -ui.board.axisValueLimit + ui.board.margin + index * ui.board.unitLength
ui.board.mapPointToUI = (gamePoint) ->
    new Point(ui.board.axisValue(gamePoint.x), ui.board.axisValue(gamePoint.y))
ui.board.mapPointFromUI = (uiPoint) ->
    f = (x) -> Math.round((x + ui.board.axisValueLimit - ui.board.margin) / ui.board.unitLength)
    new Point(f(uiPoint.x), f(uiPoint.y))
ui.board.make = (size) ->
    calcUnitLength = (size) -> 1024 / (size - 1 + ui.board.marginFactor * 2)
    emptyElement(ui.boardGrid)
    emptyElement(ui.boardStones)
    emptyElement(ui.boardMarks)
    emptyElement(ui.boardDialog)
    emptyElement(ui.info1)
    emptyElement(ui.info2)
    ui.board.hideDialog()
    hideElement(ui.boardActiveStoneReminder)
    hideElement(ui.boardPendingMove)
    ui.board.isBlocked = true
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
        p = ui.board.mapPointToUI(point)
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
            when m.nodeType == Node.ELEMENT_NODE and \
            m.gamePoint.equal(gamePoint) and \
            not m.isObsolete)[0]
ui.board.addStone = (color, gamePoint, useAnimation) ->
    p = ui.board.mapPointToUI(gamePoint)
    stoneSize = ui.board.unitLength * ui.board.stoneSizeFactor
    symbolID =
        if color == Game.COLOR_BLACK
            "blackStone"
        else if color == Game.COLOR_WHITE
            "whiteStone"
        else fail()
    element = parseElement("""
        <use x="#{-(stoneSize / 2)}" y="#{-(stoneSize / 2)}"
                width="#{stoneSize}" height="#{stoneSize}"
                transform="translate(#{p.x},#{p.y})"
                xlink:href="##{symbolID}"
                xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" />
    """)
    element.gamePoint = gamePoint
    element.stoneColor = color
    element.isObsolete = false # 吃子动画时将被吃的子的该属性设为true可防止该子被误认为仍在棋盘上
    if useAnimation
        setElementScale(element, 0.000001) # IE似乎有bug，如设为0则有时会不显示
        ui.boardStones.appendChild(element)
        scaleAnimate(element, undefined, 1, undefined, 0, 400, popTimingFunction)
    else
        ui.boardStones.appendChild(element)
ui.board.removeStone = (gamePoint, useAnimation) ->
    element = ui.board.getStone(gamePoint)
    element.isObsolete = true
    if useAnimation
        scaleAnimate(
            element, undefined, 0.000001, undefined, 200, 400, easeTimingFunction, ->
                ui.boardStones.removeChild(element)
        )
    else
        ui.boardStones.removeChild(element)
ui.board.setActiveStone = (gamePoint, color) ->
    syncTime = window.performance.now()
    reminder = ui.boardActiveStoneReminder
    if gamePoint == null
        factor = 0.5
        p = new Point(0, 0)
        box = reminder.getBBox()
        scale = 1024 / ((box.width + box.height) / 2) * factor
        rotate = if color == Game.COLOR_BLACK then 0 else 45
    else
        p = ui.board.mapPointToUI(gamePoint)
        scale = 1
        rotate = 0
    if isElementVisible(reminder)
        translateAnimate(reminder, undefined, p, syncTime, 200, 600, easeTimingFunction)
        scaleAnimate(reminder, undefined, scale, syncTime, 200, 600, easeTimingFunction)
        rotateAnimate(reminder, undefined, rotate, syncTime, 200, 600, easeTimingFunction)
    else
        setElementTranslate(reminder, p)
        setElementScale(reminder, 0.000001)
        setElementRotate(reminder, 0)
        showElement(reminder)
        scaleAnimate(reminder, undefined, scale, syncTime, 200, 600, popTimingFunction)
ui.board.updateStones = (diff, useAnimation) ->
    for i in [0...diff.length]
        item = diff[i]
        if item.color == Game.COLOR_EMPTY
            ui.board.removeStone(item.position, useAnimation)
        else
            ui.board.addStone(item.color, item.position, useAnimation)
ui.board.showDialog = (bgOpacity) ->
    ui.board.isInDialog = true
    ui.boardDialogBackground.setAttribute("opacity", "#{bgOpacity ? 0.75}")
    showElement(ui.boardDialogContainer)
ui.board.hideDialog = ->
    ui.board.isInDialog = false
    hideElement(ui.boardDialogContainer)
