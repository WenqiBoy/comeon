config      = require './config'
errors       = require './errors'
logger      = require './logger'
app         = require './app'
utils       = require './utils'

initOpts = (rootPath = '../') ->
  env:            process.env.NODE_ENV or 'development'
  configPath:     "#{rootPath}/app/configs"
  controllerPath: "#{rootPath}/app/controllers"
  modelPath:      "#{rootPath}/app/models"
  helperPath:     "#{rootPath}/app/helpers"
  middlewarePath: "#{rootPath}/app/middlewares"
  routePath:      "#{rootPath}/app/routes"
  logPath:        "#{rootPath}/logs"
  testPath:       "#{rootPath}/test"

core = {}

core.bootstrap = (rootPath = '') ->
  core.errors     = errors
  core.utils      = utils
  core.logger     = logger
  core.opts       = opts = initOpts rootPath
  core.config     = config.load opts.configPath
  core.helpers    = utils.loadModules opts.helperPath
  core

core.load = (name, module) ->
  core[name] = module

core.runServe = ->
  core.app  = app(core.opts)
  host = core.config.get('App.host') or '0.0.0.0'
  port = core.config.get('App.port') or '3000'

  core.app.listen port, host
  console.log "server listening at #{host}:#{port}"

module.exports = core