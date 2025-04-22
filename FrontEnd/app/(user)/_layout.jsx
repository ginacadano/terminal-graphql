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
        tabBarActiveTintColor: "black",
        tabBarInactiveTintColor: "rgb(119, 117, 117)",
      }}
    >
      {/* Define your tabs here */}

      <Tabs.Screen
        name="schedule"
        options={{
          title: "Schedules",
          headerShown: false,
          tabBarIcon: ({ focused, color }) => (
            <MaterialIcons name="calendar-month" size={24} color={color} />
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
