import fs from "fs";
import path from "path";
import { makeSimulation, makeRequestMumbai } from "../utils/makeChainlinkRequest";
import dotenv from "dotenv";

dotenv.config();

const consumerAddress: string = "0x62A34b8f123D8144dA6F4f91B95046a4F0Df1Af5";
const subscriptionId: number = 932;

export async function querySnapshotPoints(dao: string, username: string) : Promise<bigint | string | undefined> {
  const source: string = fs
      .readFileSync(path.resolve(__dirname, "getSnapshotPoints.js"))
      .toString();
  const args = [dao, username];
  const res = await makeSimulation(source, args);
  await makeRequestMumbai(consumerAddress, subscriptionId, source, args);
  return res;
}