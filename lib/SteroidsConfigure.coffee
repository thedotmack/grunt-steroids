
xml2js = require "xml2js"
_ = require "lodash"

makeFriendlier = (config) ->
  {
    features: pickFeatures config
  }

pickFeatures = (config) ->
  _(config.feature || [])
    .chain()
    .filter((feature) -> feature.$?.name?)
    .indexBy((feature) -> feature.$.name)
    .mapValues((feature) ->
      pickParams feature
    ).value()

pickParams = (feature) ->
  _(feature.param || [])
    .chain()
    .filter((param) -> param.$?.name?)
    .indexBy((param) -> param.$.name)
    .mapValues((param) -> param.$.value)
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
