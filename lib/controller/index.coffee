_       = require 'lodash'
Joi     = require 'Joi'
errors  = require '../errors'
utils   = require '../utils'

module.exports =

  _parseSchema: (schema, actName) ->
    (req, res, next) ->

      return next() unless _.has schema.actions, actName
      schemaDict = schema.schema
      action = schema.actions[actName]

      # 处理 required optional
      actionSchema = {}
      _.each _.keys(schemaDict), (paramKey) ->
        if _.includes action.required, paramKey
          actionSchema[paramKey] = _.clone(schemaDict[paramKey]).required()
        else if _.includes action.optional, paramKey
          actionSchema[paramKey] = _.clone(schemaDict[paramKey]).optional()
        else
          actionSchema[paramKey] = _.clone(schemaDict[paramKey]).forbidden()

      # 使用Joi做验证
      data = _.merge req.params, req.body, req.query
      result = Joi.validate(data, Joi.object().keys(actionSchema), allowUnknown:true)
      return next result.error if result.error

      # 把接收到的数据转成驼峰变量命名
      input = utils.camelCaseDeep(result.value)
      req.data = _.defaultsDeep req.data, input

      # 处理分页
      pagination = if _.has(schema, 'pagination') then schema.pagination else perpage: 20, perpageLimit: 5000
      page = _.parseInt(data._page) or 1
      page = 1 if page < 1
      limit = _parseInt(data._perpage) or pagination.perpage
      limit = pagination.perpage if limit < 1 or limit > pagination.perpageLimit
      offset = (page - 1) * limit
      req.data['_pagination'] = {limit, offset}

      # 处理输出filter
      if _.has action, 'outputFilter'
        req.data['_outputFilter'] = action.outputFilter

      next()
