_         = require 'lodash'
RestError = require './rest_error'

CODES =
  BadRequest: 400
  UnAuthorized: 401
  Forbidden: 403
  ResourceNotFound: 404
  Conflict: 409
  Invalid: 422
  Internal: 500

errors = {}

errors.RestError = RestError

_.each CODES, (statusCode, name) ->
  errors[name] = (resource = '', field = '', code = '', message = '') ->
    restError = new RestError name, statusCode
    restError.add(resource, field, code, message) if resource
    restError

module.exports = errors