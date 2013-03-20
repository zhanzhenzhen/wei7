sceneMaker["learn"] = ->
    remoteGet("/tutorial.wei7", (tutorial) ->
        elements = {}
        codifyElement(elements, """
            <table id="info1Table" style="width: 100%; height: 100%; text-align: center;"
                    xmlns="http://www.w3.org/1999/xhtml">
                <tr><td style="padding: 0 6.25%;">
                    <div id="regularMenuItems" />
                    <div style="font-size: 2em; color: rgb(104,104,104);">
                        <span id="parentButton" style="width: 20%; display: inline-block;">&#x21B0;</span>
                        <span id="backwardButton" style="width: 20%; display: inline-block;">&#x2190;</span>
                        <span id="forwardButton" style="width: 20%; display: inline-block;">&#x2192;</span>
                    </div>
                </td></tr>
            </table>
        """)
        codifyElement(elements, """
            <table id="info2Table" style="width: 100%; height: 100%;"
                    xmlns="http://www.w3.org/1999/xhtml">
                <tr><td id="commentLabel" style="padding: 0 6.25%;" /></tr>
            </table>
        """)
        elements.regularMenuItems.style.fontSize = "1.3em"
        elements.regularMenuItems.style.color = "rgb(104,104,104)"
        ui.info1.appendChild(elements.info1Table)
        elements.commentLabel.style.fontSize = "1em"
        elements.commentLabel.style.color = "rgb(104,104,104)"
        ui.info2.appendChild(elements.info2Table)
        setElementClickHandler(elements.backwardButton, ->
            moveBackward()
            refresh()
        )
        setElementClickHandler(elements.forwardButton, ->
            moveForward()
            refresh()
        )
        refresh = ->
            walker = context.scene.walker
            branch = walker.getCurrentBranch()
            emptyElement(elements.regularMenuItems)
            if (branch.steps == undefined or walker.position.stepIndex == branch.steps.length - 1) and
                    branch.branches != undefined
                for m, i in branch.branches
                    menuItem = parseElement("""
                        <div style="cursor: pointer; width: 100%; background-color: rgb(192,192,192);
                        margin: 0.5em 0; padding: 0.5em 0;"
                                xmlns="http://www.w3.org/1999/xhtml">
                            #{m.title}
                        </div>
                    """)
                    menuItem.branchIndex = i
                    do (menuItem) ->
                        setElementClickHandler(menuItem, ->
                            gotoBranch(menuItem.branchIndex)
                            refresh()
                        )
                    elements.regularMenuItems.appendChild(menuItem)
            if walker.position.stepIndex == -1
                if branch.pre != undefined and branch.pre.comment != undefined
                    elements.commentLabel.textContent = branch.pre.comment
            else
                step = branch.steps[walker.position.stepIndex]
                if step.comment != undefined
                    elements.commentLabel.textContent = step.comment
        gotoBranch = (index) ->
            walker = context.scene.walker
            if index? then walker.gotoChild(index)
            branch = walker.getCurrentBranch()
            if walker.position.stepIndex == -1
                if branch.pre != undefined
                    if branch.pre.stones != undefined
                        GameHelper.addStonesInBoard(branch.pre.stones.map((m) ->
                            {color: m.color, position: new Point(m.point.x, m.point.y)}
                        ))
            else
                step = branch.steps[walker.position.stepIndex]
                move = step.action.value
                GameHelper.playMoveInBoard({color: move.color, position: new Point(move.point.x, move.point.y)})
        moveBackward = ->
            walker = context.scene.walker
            branch = walker.getCurrentBranch()
            try
                walker.gotoPreviousStep()
                GameHelper.takebackMoveInBoard(1)
            catch e
                preStones = branch.pre?.stones
                walker.gotoParent()
                if preStones != undefined
                    GameHelper.removeStonesInBoard()
        moveForward = ->
            walker = context.scene.walker
            walker.gotoNextStep()
            branch = walker.getCurrentBranch()
            step = branch.steps[walker.position.stepIndex]
            move = step.action.value
            GameHelper.playMoveInBoard({color: move.color, position: new Point(move.point.x, move.point.y)})
        context.scene.walker = new GameRecordWalker(tutorial)
        context.scene.walker.stepCondition = (m) -> m.action.type == "move"
        ui.board.isBlocked = false
        context.game = new Game(19, Game.COLOR_BLACK)
        gotoBranch()
        refresh()
    )
