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
    <g id="homeButton" transform="translate(-768,0)" xmlns="http://www.w3.org/2000/svg">
        <circle cx="0" cy="0" r="60" stroke="rgb(0,0,0)" stroke-width="30" fill="rgb(255,255,255)" />
    </g>
""")
codifyElement(ui, """
    <g id="board" xmlns="http://www.w3.org/2000/svg">
        <rect x="-512" y="-512" width="1024" height="1024" fill="rgb(219,179,119)" />
        <g id="boardGrid" />
        <g id="boardStones" />
    </g>
""")
codifyElement(ui, """
    <radialGradient id="blackStoneGradient" r="0.5" xmlns="http://www.w3.org/2000/svg">
        <stop offset="0" stop-color="rgb(92,92,100)" />
        <stop offset="0.31" stop-color="rgb(82,82,90)" />
        <stop offset="0.62" stop-color="rgb(68,68,76)" />
        <stop offset="0.93" stop-color="rgb(48,48,56)" />
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
        <circle r="64" fill="url(#blackStoneGradient)" />
    </symbol>
""")
codifyElement(ui, """
    <symbol id="whiteStone" viewBox="-64 -64 128 128" overflow="visible" xmlns="http://www.w3.org/2000/svg">
        <circle r="64" fill="url(#whiteStoneGradient)" />
    </symbol>
""")
document.addEventListener("DOMContentLoaded", ->
    svgPoint = (x, y) ->
        p = ui.root.createSVGPoint()
        p.x = x
        p.y = y
        p
    ui.root = document.getElementById("root")
    ui.root.convertPointToScreen = (p) ->
        p.matrixTransform(ui.root.getScreenCTM())
    ui.root.convertPointFromScreen = (p) ->
        p.matrixTransform(ui.root.getScreenCTM().inverse())
    ui.root.positionLimit = ui.root.convertPointFromScreen(svgPoint(window.innerWidth, window.innerHeight))
    ui.root.appendChild(ui.blackStoneGradient)
    ui.root.appendChild(ui.whiteStoneGradient)
    ui.root.appendChild(ui.blackStone)
    ui.root.appendChild(ui.whiteStone)
    ui.root.appendChild(ui.homeButton)
    ui.board.marginFactor = 0.728
    ui.board.gridlineWidthFactor = 0.057
    ui.board.borderWidthFactor = 0.133
    ui.board.starRadiusFactor = 0.114
    ui.board.stoneSizeFactor = 0.96
    ui.board.axisValue = (index) -> -512 + ui.board.margin + index * ui.board.unitLength
    ui.board.mapPoint = (gamePoint) ->
        x: ui.board.axisValue(gamePoint.x)
        y: ui.board.axisValue(gamePoint.y)
    ui.board.make = (size) ->
        ui.board.size = size
        ui.board.unitLength = 1024 / (size - 1 + ui.board.marginFactor * 2)
        ui.board.margin = ui.board.unitLength * ui.board.marginFactor
        gridlineWidth = ui.board.unitLength * ui.board.gridlineWidthFactor
        borderWidth = ui.board.unitLength * ui.board.borderWidthFactor
        starRadius = ui.board.unitLength * ui.board.starRadiusFactor
        b = 512 - ui.board.margin
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
            drawStar({x: (size - 1) / 2, y: (size - 1) / 2})
            if size > 11
                drawStar({x: (size - 1) / 2, y: 3})
                drawStar({x: size - 1 - 3, y: (size - 1) / 2})
                drawStar({x: (size - 1) / 2, y: size - 1 - 3})
                drawStar({x: 3, y: (size - 1) / 2})
        if size > 9
            drawStar({x: 3, y: 3})
            drawStar({x: size - 1 - 3, y: 3})
            drawStar({x: 3, y: size - 1 - 3})
            drawStar({x: size - 1 - 3, y: size - 1 - 3})
    ui.board.addStone = (color, gamePoint) ->
        p = ui.board.mapPoint(gamePoint)
        stoneSize = ui.board.unitLength * ui.board.stoneSizeFactor
        symbolID =
            if color == "black"
                "blackStone"
            else if color == "white"
                "whiteStone"
            else fail()
        ui.boardStones.appendChild(parseElement("""
            <use x="#{p.x - stoneSize / 2}" y="#{p.y - stoneSize / 2}"
                    width="#{stoneSize}" height="#{stoneSize}"
                    xlink:href="##{if color == "black" then "blackStone" else "whiteStone"}"
                    xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" />
        """))
    ui.board.make(19)
    ui.board.addStone("black", {x: 0, y: 6})
    ui.board.addStone("black", {x: 0, y: 7})
    ui.board.addStone("black", {x: 0, y: 8})
    ui.board.addStone("black", {x: 0, y: 9})
    ui.board.addStone("black", {x: 1, y: 9})
    ui.board.addStone("black", {x: 1, y: 10})
    ui.board.addStone("black", {x: 2, y: 9})
    ui.board.addStone("black", {x: 2, y: 8})
    ui.board.addStone("black", {x: 2, y: 7})
    ui.board.addStone("black", {x: 2, y: 6})
    ui.board.addStone("black", {x: 3, y: 9})
    ui.board.addStone("black", {x: 3, y: 10})
    ui.board.addStone("black", {x: 4, y: 9})
    ui.board.addStone("black", {x: 4, y: 8})
    ui.board.addStone("black", {x: 4, y: 7})
    ui.board.addStone("black", {x: 4, y: 6})
    ui.board.addStone("black", {x: 7, y: 8})
    ui.board.addStone("black", {x: 8, y: 8})
    ui.board.addStone("black", {x: 9, y: 8})
    ui.board.addStone("black", {x: 10, y: 8})
    ui.board.addStone("black", {x: 10, y: 7})
    ui.board.addStone("black", {x: 9, y: 6})
    ui.board.addStone("black", {x: 8, y: 6})
    ui.board.addStone("black", {x: 7, y: 6})
    ui.board.addStone("black", {x: 6, y: 7})
    ui.board.addStone("black", {x: 6, y: 8})
    ui.board.addStone("black", {x: 6, y: 9})
    ui.board.addStone("black", {x: 7, y: 10})
    ui.board.addStone("black", {x: 8, y: 10})
    ui.board.addStone("black", {x: 9, y: 10})
    ui.board.addStone("black", {x: 10, y: 10})
    ui.board.addStone("black", {x: 12, y: 6})
    ui.board.addStone("black", {x: 12, y: 7})
    ui.board.addStone("black", {x: 12, y: 8})
    ui.board.addStone("black", {x: 12, y: 9})
    ui.board.addStone("black", {x: 12, y: 10})
    ui.board.addStone("black", {x: 12, y: 4})
    ui.board.addStone("black", {x: 14, y: 4})
    ui.board.addStone("black", {x: 15, y: 4})
    ui.board.addStone("black", {x: 16, y: 4})
    ui.board.addStone("black", {x: 17, y: 4})
    ui.board.addStone("black", {x: 18, y: 4})
    ui.board.addStone("black", {x: 17, y: 5})
    ui.board.addStone("black", {x: 17, y: 6})
    ui.board.addStone("black", {x: 16, y: 6})
    ui.board.addStone("black", {x: 16, y: 7})
    ui.board.addStone("black", {x: 16, y: 8})
    ui.board.addStone("black", {x: 15, y: 8})
    ui.board.addStone("black", {x: 15, y: 9})
    ui.board.addStone("black", {x: 15, y: 10})
    ui.board.startPosX = ui.root.positionLimit.x + 512 + 256
    ui.board.transform.baseVal.clear()
    ui.board.transform.baseVal.appendItem(ui.root.createSVGTransform())
    ui.board.transform.baseVal.getItem(0).setTranslate(ui.board.startPosX, 0)
    ui.root.appendChild(ui.board)
    valueAnimate(ui.board.startPosX, 0, 750, 400, linearTimingFunction, (value) ->
        ui.board.transform.baseVal.getItem(0).setTranslate(value, 0)
    )
    window.uiBoard = ui.board
)
