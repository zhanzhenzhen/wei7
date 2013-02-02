context =
    scene: null
    game: null
ui = {}
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
setScene = (mode) -> context.scene = {mode: mode}
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
            ui.info1.style.fontSize = "#{clientBoardTopLeft.x / 16}px"
            ui.info1.style.left = "0px"
            ui.info1.style.top = "0px"
            ui.info1.style.width = "#{clientBoardTopLeft.x}px"
            ui.info1.style.height = "#{windowHeight}px"
            ui.info2.style.fontSize = "#{clientBoardTopLeft.x / 16}px"
            ui.info2.style.left = "#{windowWidth - clientBoardTopLeft.x}px"
            ui.info2.style.top = "0px"
            ui.info2.style.width = "#{clientBoardTopLeft.x}px"
            ui.info2.style.height = "#{windowHeight}px"
            if clientBoardTopLeft.x > 128
                showElement(ui.info1)
                showElement(ui.info2)
            else
                hideElement(ui.info1)
                hideElement(ui.info2)
applyHomePage = ->
    showGameResult = ->
        emptyElement(ui.boardDialog)
        result = context.game.getResult()
        resultText =
            if context.scene.mode == "rush"
                if result? and result.winner == Game.COLOR_BLACK and
                        context.game.getPointsInColor(Game.COLOR_WHITE).length == 0
                    "闯关成功！得分：#{context.scene.timeRemaining}"
                else
                    "闯关失败"
            else
                GameHelper.getResultText(result)
        ui.board.addLabel(resultText, new Point(0, -160), 96)
        ui.board.addButton("确定", new Point(0, 160), -> ui.board.init(19, applyHomePage))
        ui.board.showDialog()
    addCommonGameButtons = ->
        ui.board.addButton("返回", new Point(0, -160), -> ui.board.hideDialog())
        ui.board.addButton("Pass", new Point(0, 0), ->
            ui.board.hideDialog()
            GameHelper.playMoveInBoard(null)
            if context.game.isEnded()
                GameHelper.applyScoringAgent(context.game)
                showGameResult()
        )
        ui.board.addButton("认输", new Point(0, 160), ->
            context.game.resign()
            showGameResult()
        )
    ui.board.addWelcomeStones()
    ui.board.addSquareButton("网", new Point(-320, 224), -> ui.board.init(19, ->
        setScene("net")
        ui.board.addButton("返回", new Point(0, 0), -> ui.board.init(19, applyHomePage))
        ui.board.showDialog()
    ))
    ui.board.addSquareButton("闲", new Point(-160, 224), -> ui.board.init(19, ->
        setScene("free")
        addCommonGameButtons()
        ui.board.isBlocked = false
        context.game = new LegalGame(19, 7.5)
    ))
    ui.board.addSquareButton("闯", new Point(0, 224), -> ui.board.init(19, ->
        setScene("rush")
        addCommonGameButtons()
        info1Table = parseElement("""
            <table style="width: 100%; height: 100%; border-collapse: collapse; text-align: center;"
                    xmlns="http://www.w3.org/1999/xhtml">
                <tr><td style="border-width: 0; padding: 1em;"></td></tr>
            </table>
        """)
        timeLabel = info1Table.getElementsByTagName("td")[0]
        timeLabel.style.fontSize = "4em"
        timeLabel.style.color = "rgb(192,0,0)"
        ui.info1.appendChild(info1Table)
        info2Table = parseElement("""
            <table style="width: 100%; height: 100%; border-collapse: collapse; text-align: center;"
                    xmlns="http://www.w3.org/1999/xhtml">
                <tr><td style="border-width: 0; padding: 1em;"></td></tr>
            </table>
        """)
        hintLabel = info2Table.getElementsByTagName("td")[0]
        hintLabel.style.fontSize = "1.3em"
        hintLabel.style.color = "rgb(96,96,96)"
        hintLabel.textContent = "您必须在500秒之内吃掉所有的白子。电脑会随机落子。" +
            "当您完成后，在屏幕空白处点一下，点击Pass即可。加油！"
        ui.info2.appendChild(info2Table)
        timeLabelText = ""
        scene = context.scene
        timespanAnimate(null, 0, 500 * 1000, (time) ->
            return false if context.scene != scene
            context.scene.timeRemaining = Math.ceil(500 - time / 1000)
            newText = context.scene.timeRemaining.toString()
            if newText != timeLabelText
                timeLabelText = newText
                timeLabel.textContent = timeLabelText
        , ->
            timeLabel.textContent = "时间到"
            showGameResult()
        )
        ui.board.isBlocked = false
        context.game = new LegalGame(19, 7.5)
    ))
    ui.board.addSquareButton("学", new Point(160, 224), -> undefined)
    ui.board.addSquareButton("谱", new Point(320, 224), -> undefined)
    helpButton = ui.board.addSquareButton("?", new Point(0, 384), undefined)
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
