import fs from "fs";
import path from "path";
import { makeSimulation, makeRequestMumbai } from "../utils/makeChainlinkRequest";
import dotenv from "dotenv";

dotenv.config();

const consumerAddress: string = "0x3c6a554d620b8fcbeb7572b32a5165346be0f1bb";
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
