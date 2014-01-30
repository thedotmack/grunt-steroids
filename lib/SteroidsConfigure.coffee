
xml2js = require "xml2js"
_ = require "lodash"

makeFriendlier = (config) ->
  {
    features: pickFeatures config
  }

indexedByName = (elements) ->
  _(elements || [])
    .chain()
    .filter((element) -> element.$?.name?)
    .indexBy((element) -> element.$.name)

pickFeatures = (config) ->
  indexedByName(config.feature)
    .mapValues((feature) ->
      indexedByName(feature.param)
        .mapValues((param) -> param.$.value)
        .value()
    )
    .value()

module.exports = 
  fromXml: (xmlString, done) ->
    xml2js.parseString(
      xmlString
      { explicitRoot: false }
      (err, rawXmlConfig) ->
        return done err if err?

        friendlyConfig = makeFriendlier rawXmlConfig

        result = JSON.stringify(friendlyConfig, null, 2)
        done null, result
    )
