import React, { useState } from "react";
import {
  StyleSheet,
  Text,
  View,
  ScrollView,
  TouchableOpacity,
  SafeAreaView,
  StatusBar,
} from "react-native";
import { Ionicons } from "@expo/vector-icons";
import { LinearGradient } from "expo-linear-gradient";
import { Link } from "expo-router";

export default function App() {
  const [selectedVehicle, setSelectedVehicle] = useState("Van");

  const destinations = [
    {
      name: "Maasin - Bato",
      schedules: [
        {
          vehicle: "Van 1",
          departure: "08:00:00",
          arrival: "09:00:00",
          date: "2029-08-09",
        },
        {
          vehicle: "Van 2",
          departure: "08:00:00",
          arrival: "09:00:00",
          date: "2029-08-09",
        },
        {
          vehicle: "Van 3",
          departure: "08:00:00",
          arrival: "09:00:00",
          date: "2029-08-09",
        },
        {
          vehicle: "Van 4",
          departure: "08:00:00",
          arrival: "09:00:00",
          date: "2029-08-09",
        },
        {
          vehicle: "Van 5",
          departure: "08:00:00",
          arrival: "09:00:00",
          date: "2029-08-09",
        },
      ],
    },
    {
      name: "Maasin - Bay-bay",
      schedules: [
        {
          vehicle: "Van 1",
          departure: "08:00:00",
          arrival: "09:00:00",
          date: "2029-08-09",
        },
        {
          vehicle: "Van 2",
          departure: "08:00:00",
          arrival: "09:00:00",
          date: "2029-08-09",
        },
        {
          vehicle: "Van 3",
          departure: "08:00:00",
          arrival: "09:00:00",
          date: "2029-08-09",
        },
        {
          vehicle: "Van 4",
          departure: "08:00:00",
          arrival: "09:00:00",
          date: "2029-08-09",
        },
        {
          vehicle: "Van 5",
          departure: "08:00:00",
          arrival: "09:00:00",
          date: "2029-08-09",
        },
      ],
    },
  ];

  const VehicleOption = ({ type, icon, isSelected }) => {
    return (
      <TouchableOpacity
        style={[
          styles.vehicleOption,
          isSelected && { borderBottomWidth: 3, borderBottomColor: "#FFA07A" },
          type === "Bus" && { backgroundColor: "#8be3c9" },
          type === "Van" && { backgroundColor: "#b5c1c1" },
          type === "Jeep" && { backgroundColor: "#c9a6db" },
        ]}
        onPress={() => setSelectedVehicle(type)}
      >
        <Text style={styles.vehicleIcon}>{icon}</Text>
        <Text style={[styles.vehicleText, isSelected && { color: "#FFA07A" }]}>
          {type}
        </Text>
      </TouchableOpacity>
    );
  };

  const ScheduleTable = ({ destination }) => {
    return (
      <View style={styles.destinationContainer}>
        <Text style={styles.destinationTitle}>
          Destination: {destination.name}
        </Text>

        <View style={styles.tableHeader}>
          <Text style={[styles.tableHeaderText, { flex: 1.5 }]}>
            Vehicle_Name
          </Text>
          <Text style={[styles.tableHeaderText, { flex: 1.5 }]}>
            Departure time
          </Text>
          <Text style={[styles.tableHeaderText, { flex: 1.5 }]}>
            Arrival time
          </Text>
          <Text style={[styles.tableHeaderText, { flex: 1 }]}>Date</Text>
        </View>

        {destination.schedules.map((schedule, index) => (
          <View key={index} style={styles.tableRow}>
            <Text style={[styles.tableCell, { flex: 1.5 }]}>
              {schedule.vehicle}
            </Text>
            <Text style={[styles.tableCell, { flex: 1.5 }]}>
              {schedule.departure}
            </Text>
            <Text style={[styles.tableCell, { flex: 1.5 }]}>
              {schedule.arrival}
            </Text>
            <Text style={[styles.tableCell, { flex: 1 }]}>{schedule.date}</Text>
          </View>
        ))}
      </View>
    );
  };

  return (
    <LinearGradient
      colors={["#b8e6b8", "#d4c1e0", "#b6d4e0"]}
      style={styles.container}
    >
      <SafeAreaView style={styles.safeArea}>
        <StatusBar translucent backgroundColor="transparent" />

        <View style={styles.header}>
          <TouchableOpacity style={styles.backButton}>
            <Link href="/(tabs)">
              <Ionicons name="arrow-back" size={24} color="#555" />
            </Link>
          </TouchableOpacity>

          <TouchableOpacity style={styles.menuButton}>
            <Ionicons name="menu" size={24} color="#555" />
          </TouchableOpacity>
        </View>

        <View style={styles.vehicleSelector}>
          <VehicleOption
            type="Bus"
            icon="🚌"
            isSelected={selectedVehicle === "Bus"}
          />
          <VehicleOption
            type="Van"
            icon="🚐"
            isSelected={selectedVehicle === "Van"}
          />
          <VehicleOption
            type="Jeep"
            icon="🚗"
            isSelected={selectedVehicle === "Jeep"}
          />
        </View>

        <ScrollView style={styles.scheduleContainer}>
          {destinations.map((destination, index) => (
            <ScheduleTable key={index} destination={destination} />
          ))}
        </ScrollView>

        {/* Footer navigation removed as requested */}
      </SafeAreaView>
    </LinearGradient>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  safeArea: {
    flex: 1,
    paddingTop: StatusBar.currentHeight || 40,
  },
  header: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
    paddingHorizontal: 20,
    paddingVertical: 10,
  },
  backButton: {
    padding: 8,
  },
  menuButton: {
    padding: 8,
  },
  vehicleSelector: {
    flexDirection: "row",
    justifyContent: "space-around",
    paddingVertical: 20,
    paddingHorizontal: 10,
  },
  vehicleOption: {
    flexDirection: "row",
    alignItems: "center",
    paddingVertical: 15,
    paddingHorizontal: 25,
    borderRadius: 25,
    shadowColor: "#000",
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  vehicleIcon: {
    fontSize: 18,
    marginRight: 8,
  },
  vehicleText: {
    fontSize: 18,
    fontWeight: "500",
  },
  scheduleContainer: {
    flex: 1,
    paddingHorizontal: 20,
    paddingBottom: 20, // Added some bottom padding for better scrolling experience
  },
  destinationContainer: {
    marginBottom: 30,
  },
  destinationTitle: {
    fontSize: 20,
    fontWeight: "500",
    color: "#555",
    marginBottom: 15,
  },
  tableHeader: {
    flexDirection: "row",
    paddingVertical: 10,
    marginBottom: 5,
  },
  tableHeaderText: {
    fontSize: 14,
    color: "#666",
    fontWeight: "500",
  },
  tableRow: {
    flexDirection: "row",
    backgroundColor: "#fff",
    borderRadius: 15,
    marginBottom: 8,
    paddingVertical: 15,
    paddingHorizontal: 10,
    shadowColor: "#000",
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.05,
    shadowRadius: 2,
    elevation: 1,
  },
  tableCell: {
    fontSize: 14,
    textAlign: "center",
  },
});
