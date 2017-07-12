Router = require "../router.js"

router =
  new Router (path, method) ->
    if method not in ["get", "post"]
      path += "?_method=" + method.toUpperCase()
    path

module.exports = router
    

