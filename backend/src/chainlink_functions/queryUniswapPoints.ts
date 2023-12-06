import fs from "fs";
import path from "path";
import { makeSimulation, makeRequestMumbai } from "../utils/makeChainlinkRequest";
import dotenv from "dotenv";

dotenv.config();

// @TODO Deploy another consumer contract dedicated to Uniswap V3
const consumerAddress: string = "0xaBe121A8f4290986d0fb1C812a1AE6E3e46C3Cf4";
const subscriptionId: number = 932;

export async function queryUniswapPoints(username: string) : Promise<bigint | string | undefined> {
  const source: string = fs
      .readFileSync(path.resolve(__dirname, "getUniswapPoint.js"))
      .toString();
  const args = [username];
  const res = await makeSimulation(source, args);
  await makeRequestMumbai(consumerAddress, subscriptionId, source, args);
  return res;
}
