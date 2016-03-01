_     = require 'lodash'
utils = require '../utils'

getValue = (object, property) ->
  elements = if _.isArray(property) then property else property.split('.')
  name = _.first(elements)
  value = object[name]
  if elements.length <= 1
    return value
  if value is null or typeof value isnt 'object'
    return undefined
  getValue value, elements.slice(1)

config = {}

config.env = process.env.NODE_ENV or 'development'

config.load = (dirPath) ->
  defaultConfigs = utils.loadModules dirPath, '', false
  envConfigs = utils.loadModules "#{dirPath}/#{config.env}/", '', false
  config.content = _.defaultsDeep envConfigs, defaultConfigs
  config

config.get = (property) ->
  throw new Error 'Calling config.get with null or undefined argument' unless property
  value = getValue config.content, property
  throw new Error "Configuration property \"#{property}\" is not defined" unless value
  value

config.has = (property) ->
  return false unless property
  getValue(config.content, property) isnt undefined

module.exports = config