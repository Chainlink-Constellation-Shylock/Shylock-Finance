import fs from "fs";
import path from "path";
import { makeSimulation, makeRequestMumbai } from "../utils/makeChainlinkRequest";
import dotenv from "dotenv";

dotenv.config();

const consumerAddress: string = "0xAD130C06E7827F2E455f31C49ea82a9879136D27";
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