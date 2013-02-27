initUIElements = ->
    codifyElement(ui, """
        <g id="board" xmlns="http://www.w3.org/2000/svg">
            <rect x="-512" y="-512" width="1024" height="1024" fill="rgb(219,179,119)" />
            <g id="boardLoads">
                <g id="boardGrid" />
                <g id="boardStones" />
                <g id="boardMarks" />
                <g id="boardPendingMove">
                    <circle r="24" fill="rgb(128,128,136)" />
                </g>
                <g id="boardActiveStoneReminder" opacity="0.25">
                    <rect x="-32" y="-32" width="64" height="64" fill="none" stroke="rgb(255,0,0)"
                            stroke-width="5" />
                </g>
            </g>
            <rect id="boardInput" x="-512" y="-512" width="1024" height="1024"
                    opacity="0" cursor="crosshair" />
            <g id="boardDialogContainer">
                <rect id="boardDialogBackground" x="-512" y="-512" width="1024" height="1024"
                        fill="rgb(224,224,224)" />
                <g id="boardDialog" />
            </g>
        </g>
    """)
    codifyElement(ui, """
        <symbol id="blackStone" viewBox="-64 -64 128 128" overflow="visible"
                xmlns="http://www.w3.org/2000/svg">
            <circle r="64" fill="rgb(128,128,136)" fill-opacity="0.625" stroke="rgb(48,48,56)"
                    stroke-width="7" />
            <circle r="56" fill="rgb(48,48,56)" />
        </symbol>
    """)
    codifyElement(ui, """
        <symbol id="whiteStone" viewBox="-64 -64 128 128" overflow="visible"
                xmlns="http://www.w3.org/2000/svg">
            <circle r="64" fill="rgb(238,238,246)" stroke="rgb(128,128,136)" stroke-width="7" />
        </symbol>
    """)
