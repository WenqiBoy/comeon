_               = require 'lodash'
Joi             = require 'Joi'
utils           = require '../utils'
baseController  = require '../controller'

router = {}

router.routes = []
router.controllers = {}

router.bind = (verb, path, actions...) ->
  controllers = router.controllers

  actions = _.map(actions, (action) ->

    return action if _.isFunction(action)

    [ctrl, act] = action.split '#'
    if !_.has(controllers, ctrl) or !_.has(controllers[ctrl], act) or !_.isFunction(controllers[ctrl][act])
      throw new Error "controller:#{ctrl} action:#{act} not found."

    return controllers[ctrl][act] unless _.has controllers[ctrl], '_schema'
    schema = controllers[ctrl]['_schema'](Joi)
    return controllers[ctrl][act] unless _.has schema.actions, act

    acts = []
    controller = _.extend controllers[ctrl], baseController
    acts.push controller._schemaValidation(schema, act)
    acts.push controller[act]
    acts
  )

  router.routes.push
    verb: verb
    path: path
    actions: _.flattenDeep actions

router.load = (opts) ->
  router.controllers = utils.loadModules(opts.controllerPath)
  require(opts.routePath)(router)
  router.routes

module.exports = router
