
tempAction = (req, res, next) ->
  console.log 'tempAction'
  next()


module.exports = (router) ->

  router.bind 'get', '/home', tempAction, "Home#index"

