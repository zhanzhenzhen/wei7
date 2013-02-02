class GameHelper
    @getResultText: (result) ->
        if not result?
            "结果未知"
        else if result.winner == Game.COLOR_BLACK
            if result.margin?
                "黑胜#{result.margin}目"
            else
                "黑中盘胜"
        else if result.winner == Game.COLOR_WHITE
            if result.margin?
                "白胜#{result.margin}目"
            else
                "白中盘胜"
        else
            "结果未知"
    @applyScoringAgent: (legalGame) ->
        score = legalGame.calculateScore()
        legalGame.setResult(score.winner, score.margin)
    @randomBot: (legalGame) ->
        testMove = (p) ->
            try
                legalGame.playMove(p)
            catch e
                return false
            legalGame.undo()
            true
        emptyPoints = legalGame.getPointsInColor(Game.COLOR_EMPTY)
        success = do ->
            for i in [0...20]
                p = randomItemInArray(emptyPoints)
                if testMove(p) then return p
            return null
        success
    @playMoveInBoard: (point) ->
        game = context.game
        oldSnapshot = game.getBoardSnapshot()
        game.playMove(point)
        newSnapshot = game.getBoardSnapshot()
        diff = Game.compareSnapshots(oldSnapshot, newSnapshot)
        ui.board.updateStones(diff, true)
        ui.board.setActiveStone(point)
        if context.scene.mode == "rush" and game.getNextColor() == Game.COLOR_WHITE
            ui.board.isBlocked = true
            window.setTimeout(->
                GameHelper.playMoveInBoard(GameHelper.randomBot(game))
                ui.board.isBlocked = false
            , 1000)
