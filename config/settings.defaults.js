// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS205: Consider reworking code to avoid use of IIFEs
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const http = require('http')
const yn = require('yn')

http.globalAgent.maxSockets = 300

const MONGO_HOST = process.env['MONGO_HOST'] || 'localhost'
const MONGO_URL =
  process.env['MONGO_URL'] || `mongodb://${MONGO_HOST}/read_only`
const PROJECT_ARCHIVER_HOST =
  process.env['PROJECT_ARCHIVER_HOST'] || 'localhost'
const HOST_LISTEN_PORT = process.env['HOST_LISTEN_PORT'] || 3038

const emailTransportParams = (() => {
  switch (process.env['EMAIL_TRANSPORT']) {
    case 'sendgrid':
      return {
        auth: {
          api_key: process.env['SENDGRID_API_KEY']
        }
      }
    case 'smtp':
      return {
        host: process.env['SMTP_HOST'],
        port: process.env['SMTP_PORT'] || 25,
        auth: {
          user: process.env['SMTP_USER'],
          pass: process.env['SMTP_PASS']
        }
      }
    default:
      return {}
  }
})()

module.exports = {
  behindProxy: yn(process.env['BEHIND_PROXY'], { default: false }),
  cookieDomain: process.env['COOKIE_DOMAIN'],
  cookieName: 'overleaf_read_only.sid',
  secureCookie: yn(process.env['SECURE_COOKIE'], { default: false }),

  apis: {
    project_archiver: {
      url: `http://${PROJECT_ARCHIVER_HOST}:3020`
    }
  },

  email: {
    fromAddress: 'Overleaf <welcome@overleaf.com>',
    replyToAddress: 'welcome@overleaf.com',
    transport: process.env['EMAIL_TRANSPORT'],
    parameters: emailTransportParams
  },

  internal: {
    read_only: {
      host: process.env['LISTEN_ADDRESS'] || 'localhost',
      port: HOST_LISTEN_PORT
    }
  },

  mongo: {
    url: MONGO_URL
  },

  security: {
    sessionSecret: process.env['SESSION_SECRET'] || 'not-so-secret'
  },

  siteUrl: process.env['PUBLIC_URL'] || `http://localhost:${HOST_LISTEN_PORT}`,

  smokeTest: {
    email: process.env['SMOKE_TEST_EMAIL'],
    password: process.env['SMOKE_TEST_PASSWORD'],
    projectId: process.env['SMOKE_TEST_PROJECT_ID']
  }
}
