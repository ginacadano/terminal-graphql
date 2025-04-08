import { Tabs } from "expo-router";
import MaterialIcons from "@expo/vector-icons/MaterialIcons";
import { LinearGradient } from "expo-linear-gradient";
import globalStyles from "../../assets/styles/globalStyles";

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
        tabBarActiveTintColor: "rgb(128, 126, 126)",
        tabBarInactiveTintColor: "black",
      }}
    >
      {/* Define your tabs here */}
      <Tabs.Screen
        name="index"
        options={{
          title: "Home",
          headerShown: false,
          tabBarIcon: ({ focused, color }) => (
            <MaterialIcons name="home" size={24} color={color} />
          ),
        }}
      />

      <Tabs.Screen
        name="vehicle"
        options={{
          title: "Vehicle",
          headerShown: false,
          tabBarIcon: ({ focused, color }) => (
            <MaterialIcons name="commute" size={25} color={color} />
          ),
        }}
      />
    </Tabs>
  );
}
