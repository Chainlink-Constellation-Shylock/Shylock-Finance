import fs from "fs";
import path from "path";
import { makeSimulation, makeRequestFuji } from "../utils/makeChainlinkRequest";
import dotenv from "dotenv";

dotenv.config();

const consumerAddress: string = "0x8d1A0328Ea8BeBa81b79F46C90528ebFcEE8E825";
const subscriptionId: number = 1865;

export async function querySnapshotPoints(dao: string, username: string) : Promise<bigint | string | undefined> {
  const source: string = fs
      .readFileSync(path.resolve(__dirname, "getSnapshotPoints.js"))
      .toString();
  const args = [dao, username];
  const res = await makeSimulation(source, args);
  await makeRequestFuji(consumerAddress, subscriptionId, source, args);
  return res;
}