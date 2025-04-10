import { mergeTypeDefs } from "@graphql-tools/merge";
import { makeExecutableSchema } from "@graphql-tools/schema";
import { rootSchema } from "./rootSchema.js";
import { userSchema } from "./userSchema.js";
import { vehicleSchema } from "./vehicleSchema.js";
import { penaltySchema } from "./penaltySchema.js";
import { scheduleSchema } from "./scheduleSchema.js";
import { loginSchema } from "./loginSchema.js";
import { penaltyResolver } from "../resolvers/penaltyResolver.js";

export const typeDefs = mergeTypeDefs([
  rootSchema,
  userSchema,
  vehicleSchema,
  scheduleSchema,
  loginSchema,
  penaltySchema,
]);

const schema = makeExecutableSchema({
  typeDefs,
  resolvers: [penaltyResolver], // Ensure resolvers are included
});

export default schema;
