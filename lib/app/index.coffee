_               = require 'lodash'
winston         = require 'winston'
express         = require 'express'
cookieParser    = require 'cookie-parser'
bodyParser      = require 'body-parser'
methodOverride  = require 'method-override'
responseTime    = require 'response-time'
morgan          = require 'morgan'
router          = require '../router'
errors          = require '../errors'
logger          = require '../logger'

catchHandler = (logger, handler) ->
  (req, res, next) ->
    try
      handler(req, res, next)
    catch err
      logger.error err.stack

module.exports = (opts) ->

  # error logger
  errorLogName = "#{opts.logPath}/error.log"
  errorLogger = logger.createInstance errorLogName
  logger.addConsole errorLogName if opts.env isnt 'production'

  # create app
  app = express()

  # disable x-powered-by
  app.disable 'x-powered-by'

  # use morgan
  app.use morgan('dev', null) if opts.env isnt 'production'

  # parse json body
  app.use bodyParser.json()
  app.use bodyParser.urlencoded(extended: true)

  # parse cookie
  app.use cookieParser()

  # method override
  # override with different headers; last one takes precedence
  app.use methodOverride('X-HTTP-Method')          # Microsoft
  app.use methodOverride('X-HTTP-Method-Override') # Google/GData
  app.use methodOverride('X-Method-Override')      # IBM

  # responseTime
  # adds a X-Response-Time header to responses
  app.use responseTime()

  # init req.data and charset
  app.use (req, res, next) ->
    req.data = {}
    res.charset = 'utf-8'
    next()

  # load custom middlewares
  middleWares = require(opts.middlewarePath)
  _.each middleWares, (middleware) ->
    app.use catchHandler(errorLogger, middleware)

  # load router
  routes = router.load(opts)
  _.each routes, (route) ->
    catchHandlers = _.map route.actions, (action) ->
      catchHandler(errorLogger, action)
    app[route.verb](route.path, catchHandlers)

  # catch 404 and forward to error handler
  app.use (req, res, next) ->
    next errors.ResourceNotFound()

  # catch errors handler
  app.use (err, req, res, next) ->
    if err instanceof errors.RestError
      return res.status(err.statusCode).json(err)
    else if _.has err, 'isJoi'
      joiError = errors.Invalid()
      _.each err.details, (detail) ->
        detail.path = detail.path.replace(/\d+/g, 'item') if _.isString(detail.path)
        joiError.add 'validate', detail.path, 'invalid', detail.message
      return res.json(joiError)
    else
      errorLogger.error err.stack
      return res.status(500).json(errors.Internal())

  # return app
  app