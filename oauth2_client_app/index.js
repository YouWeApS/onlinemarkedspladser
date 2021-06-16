/*
 * Simple client-side application used for doing oauth2 authorization code
 * flow.
 *
 * To run this: node index.js
 */

require('dotenv').config();

const credentials = {
  client: {
    id: process.env.CLIENT_ID,
    secret: process.env.CLIENT_SECRET
  },
  auth: {
    tokenHost: process.env.API_URL,
    tokenPath: "/v1/ui/oauth/token",
    authorizePath: "/v1/ui/oauth/authorize",
  }
};

const redirect_uri = process.env.CALLBACK_URL;
const scope = "user:read user:write product:read product:write order:read order:write";

const oauth2 = require('simple-oauth2').create(credentials);
const express = require('express');
const uuid = require('uuid/v4');
const bodyParser = require('body-parser');
var cors = require('cors');

var app = express();

app.use(cors());

app.use(bodyParser.json());

app.set('view engine', 'pug');

app.get('/', (req, res) => {
  res.status(200).json({ ping: 'pong' });
});

app.post('/authorize/password', async (req, res) => {
  console.log('OAuth password authorization initiated..');

  console.log(req.body);

  const tokenConfig = {
    username: req.body.username,
    password: req.body.password,
    scope,
  };
  console.log(tokenConfig);

  try {
    const result = await oauth2.ownerPassword.getToken(tokenConfig);
    console.log(result);
    const accessToken = await oauth2.accessToken.create(result);
    console.log(accessToken);
    return res.status(200).json(accessToken.token);
  } catch(e) {
    console.log(e);
    return res.status(e.output.statusCode).json({ error: e.output.payload.error });
  }
});

app.get('/authorize/code', async (req, res) => {
  console.log('OAuth code authorization initiated..');
  const state = uuid();

  // Authorization oauth2 URI
  const authorizationUri = oauth2.authorizationCode.authorizeURL({
    redirect_uri,
    scope,
    state,
  });

  console.log("Redirecting to authorization url");
  res.redirect(authorizationUri);
});

app.get('/callback', async (req, res) => {
  // TODO: Verify state (req.query.state)

  const code = req.query.code;

  // Get the access token
  const tokenConfig = { code, redirect_uri, scope };

  // Save the access token
  try {
    const result = await oauth2.authorizationCode.getToken(tokenConfig)
    const accessToken = oauth2.accessToken.create(result);
    res.render('success', { token: accessToken.token.access_token });
  } catch (error) {
    console.log('Failed to retrieve access token', error);
    return res
      .status(401)
      .json({
        error: error.message,
      });
  }
});

port = process.env.PORT;
console.log("Listening on http://localhost:", port);
app.listen(port, 'localhost');
