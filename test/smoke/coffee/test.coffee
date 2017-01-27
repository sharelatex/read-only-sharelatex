child   = require "child_process"
fs = require "fs"
Settings = require "settings-sharelatex"
logger = require "logger-sharelatex"
expect = require("chai").expect

port = Settings.internal.read_only.port

cookieFilePath = "/tmp/smoke-test-cookie-#{port}.txt"

buildUrl = (path) ->
	" -H 'Expect:' -b #{cookieFilePath} --resolve 'www#{Settings.cookieDomain}:#{port}:127.0.0.1' http://www#{Settings.cookieDomain}:#{port}/#{path}"

# Change cookie to be non secure so curl will send it
convertCookieFile = (callback) ->
	fs = require("fs")
	fs.readFile cookieFilePath, "utf8", (err, data) ->
		return callback(err) if err
		firstTrue = data.indexOf("TRUE")
		secondTrue = data.indexOf("TRUE", firstTrue+4)
		result = data.slice(0, secondTrue)+"FALSE"+data.slice(secondTrue+4)
		fs.writeFile cookieFilePath, result, "utf8", (err) ->
			return callback(err) if err
			callback()

describe "Log in and download project", ->
	it "should log in and download a project", (done) ->
		logger.log "starting smoke test"
		command =  """
			curl -H "X-Forwarded-Proto: https" -c #{cookieFilePath} --data "email=#{encodeURIComponent(Settings.smokeTest.email)}&password=#{encodeURIComponent(Settings.smokeTest.password)}" #{buildUrl('login')}
		"""
		logger.log {command}, "running curl"
		child.exec command, (err, stdout, stderr)->
			return done(err) if err?
			console.log "LOGIN STDOUT", stdout
			console.log "LOGIN STDERR", stderr
			
			expect(!!stdout.match("Found. Redirecting to /project"), "Should redirect").to.equal true

			command =  """
				curl -H "X-Forwarded-Proto: https" #{buildUrl("project/#{Settings.smokeTest.projectId}")} > /tmp/#{Settings.smokeTest.projectId}.zip
			"""
			logger.log {command}, "running curl"
			convertCookieFile (error) ->
				return done(error) if error?
				child.exec command, (error, stdout, stderr)->
					return done(err) if err?
					logger.log {stdout, stderr}, "got curl response"
					command = """
						unzip /tmp/#{Settings.smokeTest.projectId}.zip -d /tmp/#{Settings.smokeTest.projectId}
					"""
					child.exec command, (err, stdout, stderr) ->
						return done(err) if err?
						expect(!!stdout.match("inflating: /tmp/#{Settings.smokeTest.projectId}/main.tex"), "Should unzip").to.equal true
						logger.log "successfully ran smoke test"
						child.exec "rm -r /tmp/#{Settings.smokeTest.projectId} /tmp/#{Settings.smokeTest.projectId}.zip", done