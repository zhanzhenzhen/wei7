context =
    scene: null
    game: null
    postMoveHook: null
ui = {}
sceneMaker = {}
windowWidth = 0
windowHeight = 0
class BoardPointLabels
    constructor: (@boardSize) ->
        @points = (null for i in [0...size * size])
    convertPointToIndex = (point) -> point.y * @boardSize + point.x
    getLabel: (point) -> @points[convertPointToIndex(point)]
    setLabel: (point, label) -> @points[convertPointToIndex(point)] = label
parseElement = (s) -> (new DOMParser()).parseFromString(s, "application/xml").documentElement
codifyElement = (object, elementString) ->
    handle = (element) ->
        id = element.getAttribute("id")
        object[id] = element if id != null
    rootElement = parseElement(elementString)
    handle(rootElement)
    for m in rootElement.getElementsByTagName("*")
        handle(m)
initUIElements()
setScene = (mode) ->
    context.scene = {mode: mode, isEnded: false}
    context.postMoveHook = null
    sceneMaker[mode]?()
setDebugVariables = ->
    window.wei7debug = {}
    d = window.wei7debug
    d.context = context
    d.ui = ui
    d.Point = Point
    d.Game = Game
    d.LegalGame = LegalGame
    d.GameHelper = GameHelper
refreshForResize = ->
    w = window.innerWidth
    h = window.innerHeight
    if w != windowWidth or h != windowHeight
        windowWidth = w
        windowHeight = h
        ui.root.positionLimit = ui.root.convertPointFromClient(new Point(w, h))
        do ->
            clientBoardTopLeft = ui.root.convertPointToClient(new Point(-512, -512))
            fontSize = Math.min(w, h) * 0.028
            ui.info1.style.fontSize = "#{fontSize}px"
            ui.info1.style.left = "0px"
            ui.info1.style.top = "0px"
            ui.info1.style.width = "#{clientBoardTopLeft.x}px"
            ui.info1.style.height = "#{h}px"
            ui.info2.style.fontSize = "#{fontSize}px"
            ui.info2.style.left = "#{w - clientBoardTopLeft.x}px"
            ui.info2.style.top = "0px"
            ui.info2.style.width = "#{clientBoardTopLeft.x}px"
            ui.info2.style.height = "#{h}px"
            if w / h > 1.333
                showElement(ui.info1)
                showElement(ui.info2)
            else
                hideElement(ui.info1)
                hideElement(ui.info2)
applyHomePage = ->
    setScene("home")
    ui.board.addWelcomeStones()
    ui.board.addSquareButton("网", new Point(-320, 224), -> ui.board.init(19, ->
        setScene("net")
        ui.board.addButton("返回", new Point(0, 0), -> ui.board.init(19, applyHomePage))
        ui.board.showDialog()
    ))
    ui.board.addSquareButton("闲", new Point(-160, 224), -> ui.board.init(19, -> setScene("free")))
    ui.board.addSquareButton("闯", new Point(0, 224), -> ui.board.init(19, -> setScene("rush")))
    ui.board.addSquareButton("学", new Point(160, 224), undefined)
    ui.board.addSquareButton("谱", new Point(320, 224), undefined)
    helpButton = ui.board.addSquareButton("?", new Point(0, 384), -> window.open("wei7help.pdf"))
    setElementScale(helpButton, 0.5)
    context.game = null
    ui.board.showDialog(0)
document.addEventListener("DOMContentLoaded", ->
    svgPoint = (x, y) ->
        p = ui.root.createSVGPoint()
        p.x = x
        p.y = y
        p
    ui.info1 = document.getElementById("info1")
    ui.info2 = document.getElementById("info2")
    ui.root = document.getElementById("root")
    ui.root.convertPointToClient = (p) ->
        p1 = svgPoint(p.x, p.y)
        p2 = p1.matrixTransform(ui.root.getScreenCTM())
        new Point(p2.x, p2.y)
    ui.root.convertPointFromClient = (p) ->
        p1 = svgPoint(p.x, p.y)
        p2 = p1.matrixTransform(ui.root.getScreenCTM().inverse())
        new Point(p2.x, p2.y)
    ui.root.addEventListener("click", (event) ->
        p = ui.root.convertPointFromClient(new Point(event.clientX, event.clientY))
        if not (-512 <= p.x <= 512 and -512 <= p.y <= 512) and context.game != null
            ui.board.showDialog()
    )
    ui.boardInput.addEventListener("click", (event) ->
        if context.game != null and not ui.board.isBlocked
            point = ui.board.mapPointFromUI(
                ui.root.convertPointFromClient(new Point(event.clientX, event.clientY))
            )
            if 0 <= point.x < ui.board.size and 0 <= point.y < ui.board.size
                GameHelper.playMoveInBoard(point)
    )
    window.addEventListener("resize", refreshForResize)
    refreshForResize()
    ui.root.appendChild(ui.blackStoneGradient)
    ui.root.appendChild(ui.whiteStoneGradient)
    ui.root.appendChild(ui.blackStone)
    ui.root.appendChild(ui.whiteStone)
    ui.board.make(19)
    applyHomePage()
    setElementTranslate(ui.board, new Point(ui.root.positionLimit.x + 768, 0))
    ui.root.appendChild(ui.board)
    translateAnimate(ui.board, undefined, new Point(0, 0), undefined, 750, 2000,
            elasticTimingFunctionGenerator(30, 600, 5))
    setDebugVariables()
)
