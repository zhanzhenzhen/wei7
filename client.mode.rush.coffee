sceneMaker["rush"] = -> window.setTimeout(->
    totalSeconds = 600
    showGameResult = ->
        emptyElement(ui.boardDialog)
        result = context.game.getResult()
        resultText =
            if result? and result.winner == Game.COLOR_BLACK and
                    context.game.getPointsInColor(Game.COLOR_WHITE).length == 0
                "闯关成功！得分：#{context.scene.score}"
            else
                "闯关失败"
        ui.board.addLabel(resultText, new Point(0, -160), 96)
        ui.board.addButton("确定", new Point(0, 160), GoHome)
        ui.board.showDialog()
    addGameButtons = ->
        ui.board.addButton("返回", new Point(0, -160), -> ui.board.hideDialog())
        ui.board.addButton("Pass", new Point(0, 0), ->
            ui.board.hideDialog()
            GameHelper.playMoveInBoard(null)
        )
        ui.board.addButton("认输", new Point(0, 160), ->
            context.game.resign()
        )
    addGameButtons()
    info1Table = parseElement("""
        <table style="width: 100%; height: 100%; text-align: center;"
                xmlns="http://www.w3.org/1999/xhtml">
            <tr>
                <td>
                    <div />
                    <div />
                </td>
            </tr>
        </table>
    """)
    timeLabel = info1Table.getElementsByTagName("div")[0]
    scoreLabel = info1Table.getElementsByTagName("div")[1]
    timeLabel.style.fontSize = "4em"
    timeLabel.style.color = "rgb(192,0,0)"
    scoreLabel.style.fontSize = "2em"
    scoreLabel.style.color = "rgb(192,0,0)"
    ui.info1.appendChild(info1Table)
    info2Table = parseElement("""
        <table style="width: 100%; height: 100%;"
                xmlns="http://www.w3.org/1999/xhtml">
            <tr><td style="padding: 0 6.25%;"></td></tr>
        </table>
    """)
    hintLabel = info2Table.getElementsByTagName("td")[0]
    hintLabel.style.fontSize = "1.3em"
    hintLabel.style.color = "rgb(104,104,104)"
    hintLabel.textContent = "您必须在10分钟内吃掉所有的白子。电脑会随机落子。" +
            "当您完成后，在屏幕空白处点一下，再点击Pass即可。吃得越多，则得分越高。加油！"
    ui.info2.appendChild(info2Table)
    timeLabelText = ""
    context.scene.score = 0
    scoreLabel.textContent = "得分:0"
    oldScene = context.scene
    timespanAnimate(null, 0, totalSeconds * 1000, (time) ->
        return false if context.scene != oldScene or context.scene.isEnded
        context.scene.timeRemaining = Math.ceil(totalSeconds - time / 1000)
        newText = formatTimespan(context.scene.timeRemaining)
        if newText != timeLabelText
            timeLabelText = newText
            timeLabel.textContent = timeLabelText
    , ->
        context.scene.isEnded = true
        timeLabel.textContent = "时间到"
        showGameResult()
    )
    ui.board.isBlocked = false
    context.game = new LegalGame(19, 7.5)
    context.game.subscribeEvent("AfterPlayMove", ->
        context.scene.score += context.game.getLastMove().captures.length
        scoreLabel.textContent = "得分:" + context.scene.score.toString()
        if context.game.getNextColor() == Game.COLOR_WHITE
            ui.board.isBlocked = true
            window.setTimeout(->
                if not context.game.isEnded()
                    GameHelper.playMoveInBoard(GameHelper.randomBot(context.game))
                    ui.board.isBlocked = false
            , 1000)
    )
    context.game.subscribeEvent("Ended", ->
        GameHelper.applyScoringAgent(context.game) if context.game.getResult() == undefined
        context.scene.isEnded = true
        showGameResult()
    )
, 800)
