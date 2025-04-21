// import { ApolloClient, InMemoryCache } from "@apollo/client";

// const API_ENDPOINT = "https://192.168.1.11:4004"; // GraphQL endpoint

// const client1 = new ApolloClient({
//   uri: API_ENDPOINT,
//   cache: new InMemoryCache(),
// });

// export default client1;

import {
  ApolloClient,
  InMemoryCache,
  HttpLink,
  ApolloLink,
} from "@apollo/client";
import { onError } from "@apollo/client/link/error";
import * as SecureStore from "expo-secure-store";

const API_ENDPOINT = "http://192.168.1.11:4004/graphql";

const authLink = new ApolloLink(async (operation, forward) => {
  const token = await SecureStore.getItemAsync("user_token");

  operation.setContext(({ headers = {} }) => ({
    headers: {
      ...headers,
      authorization: token ? `Bearer ${token}` : "",
    },
  }));

  return forward(operation);
});

const errorLink = onError(({ graphQLErrors, networkError }) => {
  if (graphQLErrors)
    graphQLErrors.forEach(({ message, locations, path }) =>
      console.log(
        `[GraphQL error]: Message: ${message}, Location: ${locations}, Path: ${path}`
      )
    );
  if (networkError) console.log(`[Network error]: ${networkError}`);
});

const httpLink = new HttpLink({ uri: API_ENDPOINT });

const link = ApolloLink.from([authLink, errorLink, httpLink]);

const client1 = new ApolloClient({
  link,
  cache: new InMemoryCache(),
  defaultOptions: {
    watchQuery: {
      fetchPolicy: "network-only",
      errorPolicy: "all",
    },
    query: {
      fetchPolicy: "network-only",
      errorPolicy: "all",
    },
    mutate: {
      errorPolicy: "all",
    },
  },
  connectToDevTools: true,
});

export default client1;
