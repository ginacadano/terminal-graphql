import { Tabs } from "expo-router";
import MaterialIcons from "@expo/vector-icons/MaterialIcons";
import { LinearGradient } from "expo-linear-gradient";
import globalStyles from "../../assets/styles/globalStyles";
import FontAwesome6 from "@expo/vector-icons/FontAwesome6";

export default function TabsLayout() {
  return (
    <Tabs
      screenOptions={{
        tabBarBackground: () => (
          <LinearGradient
            colors={["#a1f4ff", "#c9b6e4", "#a0c7c7"]}
            start={{ x: 0, y: 0 }}
            end={{ x: 1, y: 1 }}
            style={{ flex: 1 }}
          />
        ),
        tabBarActiveTintColor: "rgb(119, 117, 117)",
        tabBarInactiveTintColor: "black",
      }}
    >
      <Tabs.Screen
        name="account"
        options={{
          title: "Account",
          headerShown: false,
          tabBarIcon: ({ focused, color }) => (
            <MaterialIcons name="people" size={24} color={color} />
          ),
        }}
      />
      <Tabs.Screen
        name="penalty"
        options={{
          title: "Penalty",
          headerShown: false,
          tabBarIcon: ({ focused, color }) => (
            <FontAwesome6 name="triangle-exclamation" size={24} color={color} />
          ),
        }}
      />
    </Tabs>
  );
}
