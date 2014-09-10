{allowUnsafeEval, allowUnsafeNewFunction} = require 'loophole'
keypair = require 'self-signed'
path = require 'path'
file = require 'file'
Promise = require 'bluebird'

fs = require 'fs'


module.exports =
class LocalHttpsServer
  _server: null

  _Hapi = null
  _cert = null
  _key = null
  _resourceDir = null
  _projectPath = null

  constructor: (projectPath, resourceDir) ->
    _projectPath = projectPath
    _resourceDir = resourceDir
    _key = path.normalize("#{__dirname}/../cert/server.key")
    _cert = path.normalize("#{__dirname}/../cert/server.cert")
    allowUnsafeNewFunction ->
      _Hapi ?= require 'hapi'
    Promise.promisifyAll(_Hapi.Server.prototype)

  stop: ->
    _server?.stop()
    console.log 'Server stopped'

  start: ->
    # create new server
    options = _configureServerOptions()
    _server = new _Hapi.Server('localhost', 0, options)

    # configure resource route
    _server.route
      method: 'GET'
      path: "/#{_resourceDir}/{path*}"
      handler:
        directory:
          path: "./#{_resourceDir}"

    # log when server ends
    _server.on 'close', (err, res) ->
      console.debug 'close'

    # start server
    _server.startAsync().then ->
      console.log '_server.info.port: ', _server.info.port
      console.log 'Server running at: ', _server.info.uri
      return _server

  _configureServerOptions = ->
    tlsOptions = []

    # use certs that already exists
    if fs.existsSync(_key) and fs.existsSync(_cert)
      tlsOptions =
        key: fs.readFileSync(_key)
        cert: fs.readFileSync(_cert)
    else
      cert = _generateCert()
      _writeCertToFs(cert)
      tlsOptions =
        key: cert.private
        cert: cert.cert

    files =
      relativeTo: _projectPath

    { tls: tlsOptions, files: files }

  _generateCert = ->
    cert = keypair
      name: "localhost"
      city: "Nashville01"
      state: "Tennessee"
      organization: "atom-sfdc-ba"
      unit: "atom-sfdc-ba"
    ,
      alt: ["127.0.0.1"]

    cert

  _writeCertToFs = (cert) ->
    file.mkdirsSync path.dirname(_key)
    file.mkdirsSync path.dirname(_cert)

    fs.writeFile _key, cert.private, (err, res) ->
    fs.writeFile _cert, cert.cert, (err, res) ->
