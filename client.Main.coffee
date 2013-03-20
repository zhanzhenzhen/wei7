context =
    localSettings: null
    cloudSettings: null
    scene: null
    game: null
ui = {}
sceneMaker = {}
windowWidth = 0
windowHeight = 0
saveLocalSettings = -> localStorage.settings = JSON.stringify(context.localSettings)
loadLocalSettings = ->
    newestSchema = "2013-02-18"
    a = localStorage.settings
    b =
        if localStorage.metaSchema == newestSchema and a?
            # 如用户不慎修改了该JSON字符串，那可能会无法解析，如不容错，那网站就永远无法正常工作
            # （除非清除浏览器的历史记录）。所以必须容错，再加上自动纠正机制。
            try
                JSON.parse(a)
            catch e
                {}
        else
            localStorage.metaSchema = newestSchema
            {}
    # 对于每项设置，设定它的默认值（如果需要）
    do ->
        b.correction ?= false
    context.localSettings = b
do ->
    loadLocalSettings()
    saveLocalSettings() # 如果本地没有这个设置，但网站已经有这个设置的话，就需要保存它的默认值
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
        # 如果在html中设width和height为100%，则iOS中若改变orientation，尺寸会调整失败
        ui.root.setAttribute("width", w.toString())
        ui.root.setAttribute("height", h.toString())
        ui.root.positionLimit = ui.root.convertPointFromClient(new Point(w, h))
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
applyHomePage = ->
    setScene("home")
    ui.board.addWelcomeStones()
    ui.board.addSquareButton("网", new Point(-320, 224), -> setScene("net"))
    ui.board.addSquareButton("闯", new Point(-160, 224), -> ui.board.init(19, -> setScene("rush")))
    ui.board.addSquareButton("自", new Point(0, 224), -> ui.board.init(19, -> setScene("free")))
    ui.board.addSquareButton("学", new Point(160, 224), -> ui.board.init(19, -> setScene("learn")))
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
        document.body.addEventListener("mousedown", preventDefaultEventHandler)
        document.body.addEventListener("mouseup", preventDefaultEventHandler)
        document.body.addEventListener("mousemove", preventDefaultEventHandler)
        if isTouchDevice
            document.body.addEventListener("touchstart", preventDefaultEventHandler)
            document.body.addEventListener("touchend", preventDefaultEventHandler)
            document.body.addEventListener("touchmove", preventDefaultEventHandler)
        [ui.info1, ui.info2].forEach((m) -> setElementClickHandler(m, ->
            if context.scene.mode != "learn" and context.game != null
                ui.board.showDialog()
        ))
        setElementHoldHandler(ui.boardInput, ->
            if context.game != null
                ui.board.showDialog()
        )
        pendingMoveTimeoutID = null
        setElementClickHandler(ui.boardInput, (event) ->
            if context.game != null and not ui.board.isBlocked and not ui.board.isInDialog
                point = ui.board.mapPointFromUI(
                    ui.root.convertPointFromClient(new Point(event.clientX, event.clientY))
                )
                if 0 <= point.x < ui.board.size and 0 <= point.y < ui.board.size
                    if context.localSettings.correction
                        setElementTranslate(ui.boardPendingMove, ui.board.mapPointToUI(point))
                        showElement(ui.boardPendingMove)
                        window.clearTimeout(pendingMoveTimeoutID) if pendingMoveTimeoutID?
                        pendingMoveTimeoutID = window.setTimeout(->
                            hideElement(ui.boardPendingMove)
                            GameHelper.playMoveInBoard(point)
                            pendingMoveTimeoutID = null
                        , 1000)
                    else
                        GameHelper.playMoveInBoard(point)
        )
    window.addEventListener("resize", refreshForResize)
    refreshForResize()
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
