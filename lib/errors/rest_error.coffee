class RestError extends Error

  constructor: (@name = 'Internal', @statusCode = 500)->
    @errors = []
    Error.captureStackTrace @, @
    return @

  add: (resource = '', field = '', code = '', message = '') ->
    @errors.push
      resource: resource
      field: field
      code: code
      message: message
    @

module.exports = RestError