
xml2js = require "xml2js"

makeFriendlier = (config) ->
  result = {}

  result.features = pickFeatures config.widget?.feature || []

  result

pickFeatures = (features) ->
  result = {}

  for feature in features when feature.$?.name?
    result[feature.$.name] = pickParams feature.param || []

  result

pickParams = (params) ->
  result = {}

  for param in params when param.$?.name? and param.$?.value?
    result[param.$.name] = param.$.value

  result

module.exports = 
  fromXml: (xmlString, done) ->
    xml2js.parseString xmlString, (err, rawXmlConfig) ->
      return done err if err?

      friendlyConfig = makeFriendlier rawXmlConfig

      result = JSON.stringify(friendlyConfig, null, 2)
      done null, result
