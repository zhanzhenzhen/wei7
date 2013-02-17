sceneMaker["settings"] = ->
    localSettings = context.localSettings
    ui.board.addLabel("本机设置", new Point(0, -400))
    ui.board.addLabel("点错纠正", new Point(-220, -280))
    correctionOnButton = ui.board.addSmallButton("开启", new Point(20, -280), ->
        ui.board.setButtonUnchecked(correctionOffButton)
        ui.board.setButtonChecked(correctionOnButton)
    )
    correctionOffButton = ui.board.addSmallButton("关闭", new Point(220, -280), ->
        ui.board.setButtonUnchecked(correctionOnButton)
        ui.board.setButtonChecked(correctionOffButton)
    )
    ui.board.addLabel("云设置", new Point(0, 0))
    ui.board.addButton("确定", new Point(-160, 360), ->
        localSettings.correction = correctionOnButton.isChecked
        saveLocalSettings()
        GoHome()
    )
    ui.board.addButton("取消", new Point(160, 360), GoHome)
    ui.board.setButtonChecked(if localSettings.correction then correctionOnButton else correctionOffButton)
    ui.board.showDialog()
