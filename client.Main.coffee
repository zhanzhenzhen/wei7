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
        ui.outsideInput.setAttribute("x", (-ui.root.positionLimit.x).toString())
        ui.outsideInput.setAttribute("y", (-ui.root.positionLimit.y).toString())
        ui.outsideInput.setAttribute("width", (ui.root.positionLimit.x * 2).toString())
        ui.outsideInput.setAttribute("height", (ui.root.positionLimit.y * 2).toString())
        do ->
            narrowFactor = (x) ->
                n = if x > 1 then 1 / x else x
                Math.min(1.746 * n + 0.333, 1)
            p = ui.root.convertPointToClient(new Point(-512, -512))
            fontSize = Math.min(w, h) * narrowFactor(if w > h then p.x / h else w / p.y) * 0.028
            ui.info1.style.fontSize = "#{fontSize}px"
            ui.info1.style.left = "0px"
            ui.info1.style.top = "0px"
            ui.info1.style.width = "#{if w > h then p.x else w}px"
            ui.info1.style.height = "#{if w > h then h else p.y}px"
            ui.info2.style.fontSize = "#{fontSize}px"
            ui.info2.style.left = "#{if w > h then w - p.x else 0}px"
            ui.info2.style.top = "#{if w > h then 0 else h - p.y}px"
            ui.info2.style.width = "#{if w > h then p.x else w}px"
            ui.info2.style.height = "#{if w > h then h else p.y}px"
            if w / h > 1.2 or w / h < 1 / 1.2
                showElement(ui.info1)
                showElement(ui.info2)
            else
                hideElement(ui.info1)
                hideElement(ui.info2)
applyHomePage = ->
    setScene("home")
    ui.board.addWelcomeStones()
    ui.board.addSquareButton("网", new Point(-320, 224), -> setScene("net"))
    ui.board.addSquareButton("闯", new Point(-160, 224), -> ui.board.init(19, -> setScene("rush")))
    ui.board.addSquareButton("闲", new Point(0, 224), -> ui.board.init(19, -> setScene("free")))
    ui.board.addSquareButton("学", new Point(160, 224), -> setScene("learn"))
    ui.board.addSquareButton("谱", new Point(320, 224), -> setScene("records"))
    settingsButton = ui.board.addSquareButton("≡", new Point(-50, 364), ->
        ui.board.init(19, -> setScene("settings"))
    )
    setElementScale(settingsButton, 0.5)
    helpButton = ui.board.addSquareButton("?", new Point(50, 364), -> window.open("wei7help.pdf"))
    setElementScale(helpButton, 0.5)
    context.game = null
    ui.board.showDialog(0)
GoHome = -> ui.board.init(19, applyHomePage)
document.addEventListener("DOMContentLoaded", ->
    svgPoint = (x, y) ->
        p = ui.root.createSVGPoint()
        p.x = x
        p.y = y
        p
    ui.info1 = document.getElementById("info1")
    ui.info2 = document.getElementById("info2")
    ui.root = document.getElementById("root")
    # *****(
    # 最好的办法其实是用getScreenCTM，但IE有bug，它不像W3C要求的那样用client pixel，
    # 而是用screen pixel。而在手机中这两者通常是不同的，由window.devicePixelRatio体现出来。
    # 但是IE又不支持window.devicePixelRatio属性，所以也无法使用getScreenCTM再通过换算来求解，
    # 因此就只能使用getCTM（这个在IE和webkit中能得到理想的值）。由于我们的svg元素没有嵌套，
    # 所以它的值和getScreenCTM的正确值是一样的，因此不会出什么问题。但这个方法在Firefox中
    # 会得到null，所以当它返回null时应该用getScreenCTM。
    ui.root.convertPointToClient = (p) ->
        p1 = svgPoint(p.x, p.y)
        p2 = p1.matrixTransform(ui.root.getCTM() ? ui.root.getScreenCTM())
        new Point(p2.x, p2.y)
    ui.root.convertPointFromClient = (p) ->
        p1 = svgPoint(p.x, p.y)
        p2 = p1.matrixTransform((ui.root.getCTM() ? ui.root.getScreenCTM()).inverse())
        new Point(p2.x, p2.y)
    # )*****
    do ->
        ui.root.addEventListener("mousedown", preventDefaultEventHandler)
        ui.root.addEventListener("mouseup", preventDefaultEventHandler)
        ui.root.addEventListener("mousemove", preventDefaultEventHandler)
        if isTouchDevice
            ui.root.addEventListener("touchstart", preventDefaultEventHandler)
            ui.root.addEventListener("touchend", preventDefaultEventHandler)
            ui.root.addEventListener("touchmove", preventDefaultEventHandler)
        setElementClickHandler(ui.outsideInput, ->
            if context.game != null
                ui.board.showDialog()
        )
        setElementHoldHandler(ui.boardInput, ->
            if context.game != null
                ui.board.showDialog()
        )
        setElementClickHandler(ui.boardInput, (event) ->
            aaa = ui.root.convertPointFromClient(new Point(event.clientX, event.clientY))
            if context.game != null and not ui.board.isBlocked and not ui.board.isInDialog
                point = ui.board.mapPointFromUI(
                    ui.root.convertPointFromClient(new Point(event.clientX, event.clientY))
                )
                if 0 <= point.x < ui.board.size and 0 <= point.y < ui.board.size
                    GameHelper.playMoveInBoard(point)
        )
    window.addEventListener("resize", refreshForResize)
    ui.root.appendChild(ui.outsideInput)
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
