import { ApolloServer } from "@apollo/server";
import { startStandaloneServer } from "@apollo/server/standalone";
import appContext from "./helpers/contextHandler.js";
import { typeDefs } from "./schema/schema.js";
import { resolvers } from "./resolvers/resolvers.js";

const server = new ApolloServer({
  typeDefs,
  resolvers,
});

const startServer = async () => {
  const { url } = await startStandaloneServer(server, {
    context: appContext,
    listen: { port: 4004 },
  });
  console.log(`🚀  Server ready at: ${url}`);
};

startServer().catch((err) => {
  console.error("Error starting server:", err);
});
