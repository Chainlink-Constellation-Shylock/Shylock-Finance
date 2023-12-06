import { ethers } from "ethers";
import {
  SubscriptionManager,
  simulateScript,
  ResponseListener,
  ReturnType,
  decodeResult,
  FulfillmentCode,
} from "@chainlink/functions-toolkit";
import functionsConsumerAbi from "./abi/functionsClient.json";

export async function makeSimulation(source: string, args: string[]): Promise<bigint | string | undefined> {
  console.log("Start simulation...");
  const response = await simulateScript({
    source: source,
    args: args,
    bytesArgs: [], // bytesArgs - arguments can be encoded off-chain to bytes.
    secrets: {}, // no secrets in this example
  });

  console.log("Simulation result", response);
  const errorString = response.errorString;
  if (errorString) {
    console.log(`❌ Error during simulation: `, errorString);
    return undefined;
  } else {
    const returnType = ReturnType.uint256;
    const responseBytesHexstring = response.responseBytesHexstring ?? "";
    let decodedResponse;
    if (ethers.utils.arrayify(responseBytesHexstring).length > 0) {
      decodedResponse = decodeResult(
        responseBytesHexstring,
        returnType
      );
      console.log(`✅ Decoded response to ${returnType}: `, decodedResponse);
      return decodedResponse;
    }
  }
}


export async function makeRequestMumbai(
  consumerAddress: string,
  subscriptionId: number,
  source: string,
  args: string[]
): Promise<void> {
  const routerAddress: string = "0x6E2dc0F9DB014aE19888F539E59285D2Ea04244C";
  const linkTokenAddress: string = "0x326C977E6efc84E512bB9C30f76E30c160eD06FB";
  const donId: string = "fun-polygon-mumbai-1";
  const explorerUrl: string = "https://mumbai.polygonscan.com";

  const gasLimit: number = 300000;

  const privateKey: string | undefined = process.env.PRIVATE_KEY;
  if (!privateKey) {
    throw new Error(
      "private key not provided - check your environment variables"
    );
  }

  const rpcUrl: string | undefined = process.env.POLYGON_MUMBAI_RPC_URL;
  if (!rpcUrl) {
    throw new Error(
      "rpcUrl not provided - check your environment variables"
    );
  }

  const provider = new ethers.providers.JsonRpcProvider(rpcUrl);
  const wallet = new ethers.Wallet(privateKey);
  const signer = wallet.connect(provider);

  ////// ESTIMATE REQUEST COSTS ////////
  console.log("\nEstimate request costs...");
  // Initialize and return SubscriptionManager
  const subscriptionManager = new SubscriptionManager({
    signer: signer,
    linkTokenAddress: linkTokenAddress,
    functionsRouterAddress: routerAddress,
  });
  await subscriptionManager.initialize();

  // estimate costs in Juels

  const gasPriceWei = await signer.getGasPrice(); // get gasPrice in wei

  const estimatedCostInJuels =
    await subscriptionManager.estimateFunctionsRequestCost({
      donId: donId, // ID of the DON to which the Functions request will be sent
      subscriptionId: subscriptionId, // Subscription ID
      callbackGasLimit: gasLimit, // Total gas used by the consumer contract's callback
      gasPriceWei: gasPriceWei.toBigInt(), // Gas price in gWei
    });

  console.log(
    `Fulfillment cost estimated to ${ethers.utils.formatEther(
    estimatedCostInJuels
    )} LINK`
  );

  //////// MAKE REQUEST ////////

  console.log("\nMake request...");

  const functionsConsumer = new ethers.Contract(
    consumerAddress,
    functionsConsumerAbi,
    signer
  );

  // Actual transaction call
  const transaction = await functionsConsumer.sendRequest(
    source, // source
    "0x", // user hosted secrets - encryptedSecretsUrls - empty in this example
    0, // don hosted secrets - slot ID - empty in this example
    0, // don hosted secrets - version - empty in this example
    args,
    [], // bytesArgs - arguments can be encoded off-chain to bytes.
    subscriptionId,
    gasLimit,
    ethers.utils.formatBytes32String(donId) // jobId is bytes32 representation of donId
  );

  // Log transaction details
  console.log(
    `\n✅ Functions request sent! Transaction hash ${transaction.hash}. Waiting for a response...`
  );

  console.log(
      `See your request in the explorer ${explorerUrl}/tx/${transaction.hash}`
  );

  const responseListener = new ResponseListener({
      provider: provider,
      functionsRouterAddress: routerAddress,
  }); // Instantiate a ResponseListener object to wait for fulfillment.

  try {
    const response = await new Promise<any>((resolve, reject) => {
      responseListener
        .listenForResponseFromTransaction(transaction.hash)
        .then((response) => {
            resolve(response); // Resolves once the request has been fulfilled.
        })
        .catch((error) => {
            reject(error); // Indicate that an error occurred while waiting for fulfillment.
        });
    });
  
    const fulfillmentCode = response.fulfillmentCode;

    if (fulfillmentCode === FulfillmentCode.FULFILLED) {
      console.log(
        `\n✅ Request ${
          response.requestId
        } successfully fulfilled. Cost is ${ethers.utils.formatEther(
          response.totalCostInJuels
        )} LINK.Complete reponse: `,
        response
      );
    } else if (fulfillmentCode === FulfillmentCode.USER_CALLBACK_ERROR) {
      console.log(
        `\n⚠️ Request ${
            response.requestId
        } fulfilled. However, the consumer contract callback failed. Cost is ${ethers.utils.formatEther(
          response.totalCostInJuels
        )} LINK.Complete reponse: `,
        response
      );
    } else {
      console.log(
        `\n❌ Request ${
            response.requestId
        } not fulfilled. Code: ${fulfillmentCode}. Cost is ${ethers.utils.formatEther(
            response.totalCostInJuels
        )} LINK.Complete reponse: `,
        response
        );
    }
  
    const errorString = response.errorString;
    if (errorString) {
      console.log(`\n❌ Error during the execution: `, errorString);
    } else {
      const responseBytesHexstring = response.responseBytesHexstring;
      if (ethers.utils.arrayify(responseBytesHexstring).length > 0) {
        const decodedResponse = decodeResult(
          response.responseBytesHexstring,
          ReturnType.uint256
        );
        console.log(
          `\n✅ Decoded response to ${ReturnType.uint256}: `,
          decodedResponse
        );
      }
    }
  } catch (error) {
    if (error instanceof Error) {
      console.error("Error listening for response:", error.message);
    } else {
      console.error("Unknown error occurred");
    }
  }
};


