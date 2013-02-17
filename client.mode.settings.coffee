sceneMaker["settings"] = ->
    ui.board.addLabel("点错纠正", new Point(-220, -240))
    correctionOnButton = ui.board.addSmallButton("开启", new Point(20, -240), ->
        ui.board.setButtonUnchecked(correctionOffButton)
        ui.board.setButtonChecked(correctionOnButton)
    )
    correctionOffButton = ui.board.addSmallButton("关闭", new Point(220, -240), ->
        ui.board.setButtonUnchecked(correctionOnButton)
        ui.board.setButtonChecked(correctionOffButton)
    )
    ui.board.addButton("确定", new Point(0, 320), GoHome)
    ui.board.showDialog()
