sceneMaker["free"] = ->
    showGameResult = ->
        emptyElement(ui.boardDialog)
        result = context.game.getResult()
        resultText =
            GameHelper.getResultText(result)
        ui.board.addLabel(resultText, new Point(0, -160), 96)
        ui.board.addButton("确定", new Point(0, 160), -> ui.board.init(19, applyHomePage))
        ui.board.showDialog()
    addGameButtons = ->
        ui.board.addButton("返回", new Point(0, -160), -> ui.board.hideDialog())
        ui.board.addButton("Pass", new Point(0, 0), ->
            ui.board.hideDialog()
            GameHelper.playMoveInBoard(null)
            if context.game.isEnded()
                GameHelper.applyScoringAgent(context.game)
                context.scene.isEnded = true
                showGameResult()
        )
        ui.board.addButton("认输", new Point(0, 160), ->
            context.game.resign()
            context.scene.isEnded = true
            showGameResult()
        )
    addGameButtons()
    ui.board.isBlocked = false
    context.game = new LegalGame(19, 7.5)
