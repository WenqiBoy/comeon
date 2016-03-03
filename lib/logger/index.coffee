_       = require 'lodash'
winston = require 'winston'

logger = {}

logger._instances = {}

logger.getInstance = (name = 'logger') ->
  logger._instances[name]

logger.addConsole = (name = 'logger') ->
  return new Error "logger:#{name} instance not found." unless _.has logger._instances, name
  logger._instances[name].add winston.transports.Console,
    colorize: true
    timestamp: true
    prettyPrint: true

logger.createInstance = (name = 'logger') ->
  return logger._instances[name] if _.has logger._instances, name
  _logger = new winston.Logger
  _logger.add winston.transports.File,
    filename: name
    timestamp: true
    prettyPrint: true
  logger._instances[name] = _logger

module.exports = logger