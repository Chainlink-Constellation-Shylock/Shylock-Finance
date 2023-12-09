import fs from "fs";
import path from "path";
import { makeSimulation, makeRequestFuji } from "../utils/makeChainlinkRequest";
import dotenv from "dotenv";

dotenv.config();

const consumerAddress: string = "0xf9Fd56F85047A1d736B9Ee26D82Ae72D20d1F9Ac";
const subscriptionId: number = 1865;

export async function queryUniswapPoints(username: string) : Promise<bigint | string | undefined> {
  const source: string = fs
      .readFileSync(path.resolve(__dirname, "getUniswapPoint.js"))
      .toString();
  const args = [username];
  const res = await makeSimulation(source, args);
  await makeRequestFuji(consumerAddress, subscriptionId, source, args);
  return res;
}
