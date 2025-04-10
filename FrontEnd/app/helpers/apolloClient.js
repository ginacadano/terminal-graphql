import { ApolloClient, InMemoryCache } from "@apollo/client";

const API_ENDPOINT = "https://192.168.0.70:4004"; // GraphQL endpoint

const client1 = new ApolloClient({
  uri: API_ENDPOINT,
  cache: new InMemoryCache(),
});

export default client1;
