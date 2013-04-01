sceneMaker["learn"] = ->
    addGameButtons = ->
        ui.board.addButton("返回", new Point(0, -80), -> ui.board.hideDialog())
        ui.board.addButton("退出", new Point(0, 80), GoHome)
    addGameButtons()
    remoteGet("/tutorial.wei7", (tutorial) ->
        elements = {}
        codifyElement(elements, """
            <table id="info1Table" style="width: 100%; height: 100%; text-align: center;"
                    xmlns="http://www.w3.org/1999/xhtml">
                <tr><td style="padding: 0 6.25%; color: rgb(104,104,104);">
                    <div id="regularMenuItems" style="font-size: 1.3em;" />
                    <div style="font-size: 2em;">
                        <div id="parentButton" style="width: 20%; display: inline-block;
            cursor: pointer;">&#x21B0;</div>
                        <div id="backwardButton" style="width: 20%; display: inline-block;
            cursor: pointer;">&#x2190;</div>
                        <div id="forwardButton" style="width: 20%; display: inline-block;
            cursor: pointer;">&#x2192;</div>
                    </div>
                    <div id="currentMoveNumberLabel" style="font-size: 1.3em; margin-top: 0.5em;" />
                </td></tr>
            </table>
        """)
        codifyElement(elements, """
            <table id="info2Table" style="width: 100%; height: 100%;"
                    xmlns="http://www.w3.org/1999/xhtml">
                <tr><td style="padding: 0 6.25%;">
                    <div id="evaluationLabel" style="text-align: center; font-size: 4em;
            color: rgb(0,128,0);" />
                    <div id="commentLabel" style="font-size: 1em; color: rgb(104,104,104);" />
                </td></tr>
            </table>
        """)
        ui.info1.appendChild(elements.info1Table)
        ui.info2.appendChild(elements.info2Table)
        setElementClickHandler(elements.parentButton, (event) ->
            gotoParent()
            refresh()
        , undefined, true)
        setElementClickHandler(elements.backwardButton, (event) ->
            moveBackward()
            refresh()
        , undefined, true)
        setElementClickHandler(elements.forwardButton, (event) ->
            moveForward()
            refresh()
        , undefined, true)
        refresh = ->
            walker = context.scene.walker
            branch = walker.getCurrentBranch()
            emptyElement(elements.regularMenuItems)
            if walker.isLastStop() and branch.branches?
                for m, i in branch.branches
                    menuItem = parseElement("""
                        <div style="cursor: pointer; width: 100%; background-color: rgb(192,192,192);
                        margin: 0.5em 0; padding: 0.5em 0;"
                                xmlns="http://www.w3.org/1999/xhtml">#{m.title}</div>
                    """)
                    menuItem.branchIndex = i
                    do (menuItem) ->
                        setElementClickHandler(menuItem, (event) ->
                            gotoBranch(menuItem.branchIndex)
                            refresh()
                        , undefined, true)
                    elements.regularMenuItems.appendChild(menuItem)
            elements.currentMoveNumberLabel.textContent =
                GameHelper.getMoveNumberText(context.game.moves.length - 1)
            elements.evaluationLabel.textContent =
                if walker.position.stepIndex == -1
                    ""
                else
                    GameHelper.getEvaluationText(branch.steps[walker.position.stepIndex]
                            .action.value.evaluation)
            elements.commentLabel.textContent =
                if walker.position.stepIndex == -1
                    branch.pre?.comment ? ""
                else
                    branch.steps[walker.position.stepIndex].comment ? ""
        gotoBranch = (index) ->
            walker = context.scene.walker
            if index? then walker.gotoChild(index)
            branch = walker.getCurrentBranch()
            if walker.position.stepIndex == -1
                if branch.pre?.stones?
                    GameHelper.addStonesInBoard(branch.pre.stones.map((m) ->
                        {color: m.color, position: new Point(m.point.x, m.point.y)}
                    ))
            else
                playMove()
        gotoParent = ->
            walker = context.scene.walker
            branch = walker.getCurrentBranch()
            stepIndex = walker.position.stepIndex
            walker.gotoParent()
            if branch.steps? and stepIndex >= 0
                GameHelper.takebackMovesInBoard(branch.steps[..stepIndex]
                        .filter(walker.stopCondition).length)
            if branch.pre?.stones?
                GameHelper.removeStonesInBoard()
        moveBackward = ->
            walker = context.scene.walker
            branch = walker.getCurrentBranch()
            try
                walker.gotoPreviousStop()
                GameHelper.takebackMovesInBoard(1)
            catch e
                preStones = branch.pre?.stones
                walker.gotoParent()
                if preStones?
                    GameHelper.removeStonesInBoard()
        moveForward = ->
            walker = context.scene.walker
            walker.gotoNextStop()
            playMove()
        playMove = ->
            walker = context.scene.walker
            branch = walker.getCurrentBranch()
            step = branch.steps[walker.position.stepIndex]
            move = step.action.value
            GameHelper.playMoveInBoard(
                color: move.color
                position: new Point(move.point.x, move.point.y)
            )
        context.scene.walker = new GameRecordWalker(tutorial)
        context.scene.walker.stopCondition = (m) -> m.action.type == "move"
        # ui.board.isBlocked = false
        context.game = new Game(19, Game.COLOR_BLACK)
        gotoBranch()
        refresh()
    )
