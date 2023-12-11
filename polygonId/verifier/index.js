const express = require("express");
const { auth, resolver, protocol } = require("@iden3/js-iden3-auth");
const getRawBody = require("raw-body");
const path = require("path");
const { Web3 } = require("web3");
const web3 = new Web3("https://rpc-mumbai.maticvigil.com/");

const app = express();
const port = 8080;

const contractABI = [
  /* ... Governance Contract ABI ... */
];
const contractAddress = "0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee";
const privateKey = "0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee";

const contract = new web3.eth.Contract(contractABI, contractAddress);

let hostUrl = "http://127.0.0.1:8080";

app.use(express.json());
app.use(express.static("static"));

app.get("/api/sign-in", (req, res) => {
  console.log("get Auth Request");
  GetAuthRequest(req, res);
});

app.post("/api/callback", (req, res) => {
  console.log("callback");
  Callback(req, res);
});

app.post("/api/update-host", (req, res) => {
  console.log("Updating host URL");
  updateHostUrl(req, res);
});

app.listen(port, () => {
  console.log("server running on port 8080");
});

// Create a map to store the auth requests and their session IDs
const requestMap = new Map();

async function sendKYCCompletionTransaction(userId) {
  const account = web3.eth.accounts.privateKeyToAccount(privateKey);
  web3.eth.accounts.wallet.add(account);

  const data = contract.methods.recordKYCCompletion(userId).encodeABI();

  const tx = {
    from: account.address,
    to: contractAddress,
    gas: 2000000,
    data: data,
  };

  try {
    const signedTx = await web3.eth.accounts.signTransaction(tx, privateKey);
    const receipt = await web3.eth.sendSignedTransaction(
      signedTx.rawTransaction
    );
    console.log("Transaction receipt:", receipt);
  } catch (error) {
    console.error("Transaction error:", error);
  }
}

// GetQR returns auth request
async function GetAuthRequest(req, res) {
  // Audience is verifier id
  const sessionId = 1;
  const callbackURL = "/api/callback";
  const audience =
    "did:polygonid:polygon:mumbai:2qDyy1kEo2AYcP3RT4XGea7BtxsY285szg6yP9SPrs";

  const uri = `${hostUrl}${callbackURL}?sessionId=${sessionId}`;

  // Generate request for basic authentication
  const request = auth.createAuthorizationRequest("test flow", audience, uri);

  request.id = "7f38a193-0918-4a48-9fac-36adfdb8b542";
  request.thid = "7f38a193-0918-4a48-9fac-36adfdb8b542";

  // Add request for a specific proof
  const proofRequest = {
    id: 1,
    circuitId: "credentialAtomicQuerySigV2",
    query: {
      allowedIssuers: ["*"],
      type: "KYC",
      context: "ipfs://QmNrDfpNdGEaTDUm61GXH62s2AF72QzBA4MUZLquxrB6B2",
      credentialSubject: {
        gotKYC: {
          $eq: true,
        },
      },
    },
  };
  const scope = request.body.scope ?? [];
  request.body.scope = [...scope, proofRequest];

  // Store auth request in map associated with session ID
  requestMap.set(`${sessionId}`, request);

  return res.status(200).set("Content-Type", "application/json").send(request);
}

// Callback verifies the proof after sign-in callbacks
async function Callback(req, res) {
  // Get session ID from request
  const sessionId = req.query.sessionId;

  // get JWZ token params from the post request
  const raw = await getRawBody(req);
  const tokenStr = raw.toString().trim();

  const ethURL = "https://rpc-mumbai.maticvigil.com/";
  const contractAddress = "0x134B1BE34911E39A8397ec6289782989729807a4";
  const keyDIR = "../keys";

  const ethStateResolver = new resolver.EthStateResolver(
    ethURL,
    contractAddress
  );

  const resolvers = {
    ["polygon:mumbai"]: ethStateResolver,
  };

  // fetch authRequest from sessionID
  const authRequest = requestMap.get(`${sessionId}`);

  // EXECUTE VERIFICATION
  const verifier = await auth.Verifier.newVerifier({
    stateResolver: resolvers,
    circuitsDir: path.join(__dirname, keyDIR),
    ipfsGatewayURL: "https://ipfs.io",
  });

  try {
    const opts = {
      AcceptedStateTransitionDelay: 5 * 60 * 1000, // 5 minute
    };
    authResponse = await verifier.fullVerify(tokenStr, authRequest, opts);
  } catch (error) {
    return res.status(500).send(error);
  }

  await sendKYCCompletionTransaction(authResponse.from);

  console.log("authResponse", authResponse);

  return res
    .status(200)
    .set("Content-Type", "application/json")
    .send("user with ID: " + authResponse.from + " Succesfully authenticated");
}

function updateHostUrl(req, res) {
  const newHostUrl = req.body.hostUrl;
  if (!newHostUrl) {
    return res.status(400).send("No host URL provided");
  }

  hostUrl = newHostUrl;
  console.log(`Updated host URL to: ${hostUrl}`);
  return res.status(200).send(`Host URL updated to: ${hostUrl}`);
}
