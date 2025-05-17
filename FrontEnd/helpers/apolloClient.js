import {
  ApolloClient,
  InMemoryCache,
  HttpLink,
  ApolloLink,
} from "@apollo/client";
import { onError } from "@apollo/client/link/error";
import { setContext } from "@apollo/client/link/context";
import * as SecureStore from "expo-secure-store";
import { useNavigation } from "@react-navigation/native"; // Import for navigation

const API_ENDPOINT = "http://192.168.68.113:4004/graphql";

// Create Apollo Client instance (with navigation added)
const authLink = setContext(async (_, { headers }) => {
  const token = await SecureStore.getItemAsync("user_token");
  return {
    headers: {
      ...headers,
      authorization: token ? `Bearer ${token}` : "",
    },
  };
});

// Error Link to handle expired/invalid tokens
const errorLink = onError(({ graphQLErrors, networkError }) => {
  const navigation = useNavigation(); // Hook for navigation

  if (graphQLErrors) {
    for (let err of graphQLErrors) {
      if (
        err.message.toLowerCase().includes("invalid token") ||
        err.message.toLowerCase().includes("jwt expired")
      ) {
        // Delete token on invalid expiration
        SecureStore.deleteItemAsync("user_token");

        // Route to login screen
        navigation.navigate("Login"); // Assuming you have a Login screen setup

        // Optionally, you can also add a custom alert or message
        console.warn("Token expired. Please log in again.");
      }
    }
  }

  if (networkError) {
    console.log(`[Network error]: ${networkError}`);
  }
});

// HTTP Link to define the GraphQL endpoint
const httpLink = new HttpLink({ uri: API_ENDPOINT });

// Combine the links (authLink, errorLink, httpLink) together
const link = ApolloLink.from([authLink, errorLink, httpLink]);

// Apollo Client setup
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
