{exec} = require("child_process")
task("build", "build app", ->
    exec("coffee --join server.js --compile shared.*.coffee server.*.coffee")
    exec("coffee --join client.js --compile shared.*.coffee client.*.coffee")
)
