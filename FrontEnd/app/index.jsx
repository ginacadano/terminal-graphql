import { useEffect } from "react";
import { router } from "expo-router";
import * as SecureStore from "expo-secure-store";
import { View, ActivityIndicator } from "react-native";

export default function Index() {
  useEffect(() => {
    const checkAuth = async () => {
      try {
        const token = await SecureStore.getItemAsync("user_token");
        const userType = await SecureStore.getItemAsync("user_type");

        if (!token || !userType) {
          router.replace("/(tabs)");
        } else if (userType === "admin") {
          router.replace("/(admin)/account");
        } else {
          router.replace("/(tabs)");
        }
      } catch (e) {
        console.error("Error checking auth:", e);
        router.replace("/(tabs)");
      }
    };

    checkAuth();
  }, []);

  return (
    <View
      style={{
        flex: 1,
        justifyContent: "center",
        alignItems: "center",
        backgroundColor: "#000",
      }}
    >
      <ActivityIndicator size="large" color="#22C55E" />
    </View>
  );
}
