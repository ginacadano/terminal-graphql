import { scheduleResolver } from "./scheduleResolver.js";
import { userResolver } from "./userResolver.js";
import { vehicleResolver } from "./vehicleResolver.js";
import { penaltyResolver } from "./penaltyResolver.js";
import { loginResolver } from "./loginResolver.js";

export const resolvers = {
  Query: {
    ...userResolver.Query,
    ...vehicleResolver.Query,
    ...scheduleResolver.Query,
    ...penaltyResolver.Query,
  },
  Mutation: {
    ...loginResolver.Mutation,
    ...userResolver.Mutation,
    ...vehicleResolver.Mutation,
    ...scheduleResolver.Mutation,
    ...penaltyResolver.Mutation,
  },
};
