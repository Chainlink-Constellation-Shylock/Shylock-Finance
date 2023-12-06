const theGraphUrl = "https://api.studio.thegraph.com/query/44690/uniswap-v3-subgraph/version/latest";

/* Components used to query The Graph API */

/**
 * Method to query time-weighted user liquidity and user swap volume in Uniswap V3.
 * @param input Includes the address of user to query
 * @returns The array of time-weighted user liquidity and user swap volume
 */
const queryTradingVolume = async (input) => {
  let queriedVolume = await _queryTradingVolume(input.user);
  if (queriedVolume.user == null) {
    return [0, 0];
  }
  let twLiqUSD = queriedVolume.user.twLiqUSD;
  let volume = queriedVolume.user.volumeUSD;

  return [twLiqUSD, volume];
}

const _queryTradingVolume = async (address) => {
  const query = `
      query GetUniswapUser($address: String!) { 
        user (
          id: $address
        ) {
          twLiqUSD
          volumeUSD
        }
      }`;
  const variables = {
    "address": address,
  };
  const operationName = "GetUniswapUser";
  const response = await _queryGraphQL(query, variables, operationName);
  return response.data;
}


const _queryGraphQL = async (query, variables = {}, operationName = "") => {
  const data = JSON.stringify({
    query: query,
    variables: variables,
    operationName: operationName,
  });

  const uniswapQueryResponse = await fetch(theGraphUrl, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: data,
  });

  if (uniswapQueryResponse.error) {
    const responseBody = await uniswapQueryResponse.response.json();
    console.error('Detailed Response Body:', responseBody);
    throw new Error(
      `'Detailed Response Body:', ${responseBody}`
    );
  };
  const res = await uniswapQueryResponse.json();
  return res;
}

/* Main */

const user = args[0];
console.log(`Getting Protocol Activity Score for ${user} in Uniswap V3`);

/**
 * To calculate the on-chain activity score for a given user in Uniswap.
 * @param user Address of the user to query
 * @returns Score of the user in Uniswap
 */
const calculateUniswapScore = async (user) => {
  const [twLiqUSD, volumeUSD] = await queryTradingVolume({user: user});
  console.log(`Total Trading Volume for ${user} is ${volumeUSD}`);
  console.log(`Total TWLiqUSD for ${user} is ${twLiqUSD}`);
  let score = 0;
  // @TODO Correct calculation of score
  score += twLiqUSD;
  score += volumeUSD;
  return score;
}

let score = 0;
score += await calculateUniswapScore(user);

console.log(`Activity Score for ${user} in ${space} is ${score}`);

return Functions.encodeUint256(Math.round(score));
