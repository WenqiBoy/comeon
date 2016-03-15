path  = require 'path'
glob  = require 'glob'
_     = require 'lodash'
humps = require 'humps'

utils =

  # load modules
  loadModules: (modulesPath = '', suffix = '', isDeep = true, isUpperFirst = true) ->
    modules = {}
    deepDir = if isDeep then '**/' else ''
    filePaths = glob.sync "#{modulesPath}/#{deepDir}*.coffee", ignore:['./index.coffee']
    for filePath in filePaths
      fileName = path.basename filePath, '.coffee'
      moduleName = _.camelCase fileName
      moduleName = _.upperFirst moduleName if isUpperFirst
      modules["#{moduleName}#{suffix}"] = require filePath
    return modules


  camelCaseDeep: (obj) ->
    humps.camelizeKeys(obj)

  snakeCaseDeep: (obj, opts = {}) ->
    humps.decamelizeKeys(obj, opts)


module.exports = utils