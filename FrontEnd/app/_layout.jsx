import { Stack } from "expo-router";
import { ApolloProvider } from "@apollo/client";
import client1 from "./helpers/apolloClient";
import { useEffect, useState } from "react";
import { View, ActivityIndicator, Text, StyleSheet } from "react-native";

export default function RootLayout() {
  const [isReady, setIsReady] = useState(false);
  const [tokenLoaded, setTokenLoaded] = useState(false);

  useEffect(() => {
    const loadToken = async () => {
      try {
        const token = await SecureStore.getItemAsync("user_token");
        console.log("Token loaded at startup:", token);
      } catch (e) {
        console.log("Error loading token", e);
      } finally {
        setTokenLoaded(true);
      }
    };

    loadToken();
    setIsReady(true);
  }, []);

  if (!isReady || !tokenLoaded) {
    return (
      <View style={styles.loadingContainer}>
        <ActivityIndicator size="large" color="#CDD6F4" />
        <Text style={styles.loadingText}>Loading application...</Text>
      </View>
    );
  }

  return (
    <ApolloProvider client={client1}>
      <Stack screenOptions={{ headerShown: false }}>
        <Stack.Screen name="index" />
        <Stack.Screen name="(tabs)" />
        <Stack.Screen name="(admin)" />
      </Stack>
    </ApolloProvider>
  );
}

const styles = StyleSheet.create({
  loadingContainer: {
    flex: 1,
    justifyContent: "center",
    alignItems: "center",
    backgroundColor: "#1E1E2E",
  },
  loadingText: {
    marginTop: 10,
    color: "#CDD6F4",
  },
});
