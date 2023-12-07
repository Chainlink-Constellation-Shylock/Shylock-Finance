const snapshotUrl = "https://hub.snapshot.org/graphql";

/* Components used to query Snapshot API */

/**
 * Method to query all proposals in a given space.
 * @param input Includes the space of the proposals to query (state is optional)
 * @returns The ids of all proposals in the given space
 */
const queryAllProposals = async (input) => {
  let queriedProposal = await _queryAllProposals(input.space);
  return queriedProposal.proposals;  
}

/**
 * Use this method to query the total score of all proposals in a given space.
 * @param input Includes the proposals to query
 * @returns The scores of all proposals in the given space
 */
const queryAllProposalScores = async(input) => {
  let proposalScores = input.proposals
    .map(proposal => proposal.scores.reduce((sum, score) => sum + score, 0))
    .reduce((total, currentSum) => total + currentSum, 0);
  return proposalScores;
}

/**
 * Use this method to query the number of proposals in a given space by a given author.
 * @param input Includes the space and author of the proposals to query
 * @returns The number of proposals in the given space by the given author
 */
const queryProposalAuthorCount = async(input) => {
  let proposalAuthorCount = input.proposals.reduce((acc, proposal) => {
    if (proposal.author === input.author) {
      return acc + 1;
    }
    return acc;
  }, 0);
  return proposalAuthorCount;
}

const _queryAllProposals = async (space) => {
  const query =`
    query GetTotalProposals($space: String!) {
      proposals (
        first: 80,
        skip: 0,
        where: {
          space: $space,
          state: "closed"
        },
        orderBy: "created",
        orderDirection: desc
      ) {
        id
        author
        created
        scores
      }
    }`;
  const variables = {"space": space};
  const operationName = "GetTotalProposals";
  const response = await _queryGraphQL(query, variables, operationName);
  return response.data;
}

/**
 * Use this method to query the voting power of a given voter for a given proposal.
 * @param input Includes the space, voter, and proposal to query
 * @returns The voting power of the given voter for the given proposal
*/
const queryVotingPowerForProposals = async (input) => {
  let queriedVotes =
    await _queryVotingPowerForProposals(
      input.space,
      input.voter,
      input.proposalIn
    );
  if (queriedVotes.votes.length === 0) {
    return 0;
  }
  let votingPower = queriedVotes.votes.reduce((acc, vote) => acc + vote.vp, 0);
  return votingPower;
}

const _queryVotingPowerForProposals = async (space, voter, proposalIn) => {
  const query = `
      query GetAllVotingPower($space: String!, $voter: String!, $proposalIn: [String!]!) { 
        votes (
          first: 500,
          skip: 0,
          where: {
            space: $space,
            voter: $voter,
            proposal_in: $proposalIn
          },
          orderBy: "created",
          orderDirection: asc
        ) {
          vp
        }
      }`;
  const variables = {
    "space": space,
    "voter": voter,
    "proposalIn": proposalIn
  };
  const operationName = "GetAllVotingPower";
  const response = await _queryGraphQL(query, variables, operationName);
  return response.data;
}

const _queryGraphQL = async (query, variables = {}, operationName = "") => {
  const data = JSON.stringify({
    query: query,
    variables: variables,
    operationName: operationName,
  });

  const snapshotQueryResponse = await fetch(snapshotUrl, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: data,
  });

  if (snapshotQueryResponse.error) {
    const responseBody = await snapshotQueryResponse.response.json();
    console.error('Detailed Response Body:', responseBody);
    throw new Error(
      `'Detailed Response Body:', ${responseBody}`
    );
  };
  const res = await snapshotQueryResponse.json();
  return res;
}

/* Main */

const space = args[0];
const user = args[1];
console.log(`Getting Activity Score for ${user} in ${space}`);

const splitArrayIntoChunks = (array, chunkSize) => {
  let result = [];
  for (let i = 0; i < array.length; i += chunkSize) {
    let chunk = array.slice(i, i + chunkSize);
    result.push(chunk);
  }
  return result;
}

/**
 * To calculate the activity score for a given user in a given space in Snapshot.
 * @param space Name of the space to query
 * @param user Address of the user to query
 * @returns Score of the user in the given space
 */
const calculateSnapshotScore = async (space, user) => {
  const totalProposals = await queryAllProposals({space: space});
  console.log(`Total Proposals in ${space} is ${totalProposals.length}`);
  let proposalIds = totalProposals.map(proposal => proposal.id);

  // To avoid payload size limit which is 2048 bytes,
  // we split the array of proposal ids into chunks of 20
  const chunkedProposals = splitArrayIntoChunks(proposalIds, 20);
  let votingPowerCount = 0;

  const length = chunkedProposals.length < 3 ? chunkedProposals.length : 3;
  for (let i = 0; i < length; i++) {
    const chunkedProposalIds = chunkedProposals[i];
    votingPowerCount += await queryVotingPowerForProposals({
      space: space,
      voter: user,
      proposalIn: chunkedProposalIds
    });
    console.log(`Voting Power Count for ${user} in ${space} is ${votingPowerCount}`);
  }

  const totalVotingPower = await queryAllProposalScores({proposals: totalProposals});
  console.log(`Total Voting Power for in ${space} is ${totalVotingPower}`);
  console.log(`Ratio of voting power for ${user} in ${space} is ${votingPowerCount / totalVotingPower}`)
  const authorCount = await queryProposalAuthorCount({proposals: totalProposals, author: user});

  let score = 0;

  const ratio = votingPowerCount / totalVotingPower;
  // Max score for snapshot votes is 100
  // Relationship between voting power ratio and score is logarithmic
  // score = 25 * log10(votingPowerRatio) + 125
  if (ratio > 0.00001) {
    score += 25 * Math.log10(ratio) + 125;
  }

  // Multiplier for author count is 3
  if (authorCount > 0) {
    score += authorCount * 3;
  }

  // Max score for snapshot votes is 100
  if (score > 100) {
    score = 100;
  }

  return score;
}

let score = await calculateSnapshotScore(space, user);

console.log(`Activity Score for ${user} in ${space} is ${score}`);

return Functions.encodeUint256(Math.round(score));
