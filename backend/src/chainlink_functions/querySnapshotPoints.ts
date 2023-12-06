import fs from "fs";
import path from "path";
import { makeSimulation, makeRequestMumbai } from "../utils/makeChainlinkRequest";
import dotenv from "dotenv";

dotenv.config();

const consumerAddress: string = "0xaBe121A8f4290986d0fb1C812a1AE6E3e46C3Cf4";
const subscriptionId: number = 932;

export async function querySnapshotPoints(dao: string, username: string) : Promise<bigint | string | undefined> {
  const source: string = fs
      .readFileSync(path.resolve(__dirname, "getSnapshotPoint.js"))
      .toString();
  const args = [dao, username];
  const res = await makeSimulation(source, args);
  await makeRequestMumbai(consumerAddress, subscriptionId, source, args);
  return res;
}
