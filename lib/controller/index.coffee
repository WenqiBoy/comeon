_       = require 'lodash'
Joi     = require 'Joi'
errors  = require '../errors'

module.exports =

  _schemaValidation: (schema, actName) ->
    (req, res, next) ->
      return next() unless _.has schema.actions, actName
      schemaDict = schema.schema
      action = schema.actions[actName]

      actionSchema = {}
      _.each _.keys(schemaDict), (paramKey) ->
        if _.includes action.required, paramKey
          actionSchema[paramKey] = _.clone(schemaDict[paramKey]).required()
        else if _.includes action.optional, paramKey
          actionSchema[paramKey] = _.clone(schemaDict[paramKey]).optional()
        else
          actionSchema[paramKey] = _.clone(schemaDict[paramKey]).forbidden()

      validateSchema = Joi.object().keys(actionSchema)
      data = _.merge req.params, req.body, req.query
      result = Joi.validate(data, validateSchema, allowUnknown:true)
      return next result.error if result.error

      valueKeys = _.keys(result.value)
      _.each valueKeys, (key) ->
        req.input[_.camelCase(key)] = result.value[key]
      next()
