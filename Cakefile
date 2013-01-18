{exec} = require("child_process")
handler = (label) ->
    (error, stdout, stderr) ->
        console.log(label + ": " + (if error == null then "success" else "failure"))
        if error != null
            console.log("Error:")
            console.log(error)
        console.log("********************************")
task("build", "build app", ->
    exec("coffee --join server.js --compile shared.*.coffee server.*.coffee", handler("server.js"))
    exec("coffee --join client.js --compile shared.*.coffee client.*.coffee", handler("client.js"))
)
