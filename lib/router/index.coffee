_           = require 'lodash'
Joi         = require 'Joi'
utils       = require '../utils'
controller  = require '../controller'

router = {}

router.routes = []
router.controllers = {}

router.bind = (verb, path, actions...) ->
  controllers = router.controllers

  actions = _.map(actions, (action) ->

    return action if _.isFunction(action) or _.isArray(action)

    # 解析 controller#action
    [ctrl, act] = action.split '#'
    if !_.has(controllers, ctrl) or !_.has(controllers[ctrl], act)
      throw new Error "controller:#{ctrl} action:#{act} not found."

    acts = []
    # 解析schema
    if _.has controllers[ctrl], '_schema'
      schema = controllers[ctrl]['_schema'](Joi)
      if _.has schema.actions, act
        acts.push controller._parseSchema(schema, act)

    # 处理beforeAction
    if _.has(controllers[ctrl], '_beforeAction') and _.isFunction(controllers[ctrl])
      acts.push controllers[ctrl]['_beforeAction']

    # 添加目标action
    acts.push controllers[ctrl][act]

    acts
  )

  router.routes.push
    verb: verb
    path: path
    actions: _.flattenDeep actions

router.load = (opts) ->
  router.controllers = utils.loadModules opts.controllerPath, '', false
  require(opts.routePath)(router)
  router.routes

module.exports = router
