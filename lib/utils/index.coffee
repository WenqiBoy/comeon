path  = require 'path'
glob  = require 'glob'
_     = require 'lodash'

utils =

  # load modules
  loadModules: (modulesPath = '', suffix = '', isDeep = true) ->
    modules = {}
    deepDir = if isDeep then '**/' else ''
    filePaths = glob.sync "#{modulesPath}/#{deepDir}*.coffee", ignore:['./index.coffee']
    for filePath in filePaths
      fileName = path.basename filePath, '.coffee'
      moduleName = _.upperFirst _.camelCase fileName
      modules["#{moduleName}#{suffix}"] = require filePath
    return modules

module.exports = utils