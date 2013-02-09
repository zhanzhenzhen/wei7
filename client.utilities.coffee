formatTimespan = (seconds, hasHour, isFirstFixed) ->
    twoDigits = (n) -> (if n < 10 then "0" else "") + n.toString()
    n = seconds
    if hasHour
        h = Math.floor(n / 3600)
        n = seconds - h * 3600
    m = Math.floor(n / 60)
    n = seconds - m * 60
    s = Math.floor(n)
    if hasHour
        if isFirstFixed
            "#{twoDigits(h)}:#{twoDigits(m)}:#{twoDigits(s)}"
        else
            "#{h}:#{twoDigits(m)}:#{twoDigits(s)}"
    else
        if isFirstFixed
            "#{twoDigits(m)}:#{twoDigits(s)}"
        else
            "#{m}:#{twoDigits(s)}"
