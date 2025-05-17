import React, { useState } from "react";
import {
  Text,
  View,
  StyleSheet,
  TouchableOpacity,
  SafeAreaView,
  ScrollView,
} from "react-native";
import { Ionicons } from "@expo/vector-icons";
import { LinearGradient } from "expo-linear-gradient";
import { Link } from "expo-router";
import { useRouter } from "expo-router";
import AntDesign from "@expo/vector-icons/AntDesign";
export default function Index() {
  const [selectedVehicle, setSelectedVehicle] = useState(null);

  return (
    <LinearGradient
      colors={["#a1f4ff", "#c9b6e4", "#a0c7c7"]}
      style={styles.container}
    >
      <SafeAreaView style={styles.safeArea}>
        {/* Menu Icon */}

        <View style={styles.menuContainer}>
          <TouchableOpacity onPress={() => router.push('/login')}>
            <Text>Log-In</Text>
            
          </TouchableOpacity>
        </View>

        {/* Main Content */}
        <ScrollView contentContainerStyle={styles.scrollContent}>
          {/* Header Banner */}
          <View style={styles.headerBanner}>
            <Text style={styles.headerText}>Happy Safe Trip!</Text>
          </View>

          {/* Vehicle Selection */}
          <View style={styles.section}>
            <Text style={styles.sectionTitle}>Vehicles:</Text>
            <View style={styles.vehiclesContainer}>
              <TouchableOpacity
                style={[
                  styles.vehicleButton,
                  selectedVehicle === "bus" && styles.selectedVehicle,
                  styles.busButton,
                ]}
                onPress={() => setSelectedVehicle("bus")}
              >
                <Text style={styles.vehicleText}>🚌 Bus</Text>
              </TouchableOpacity>

              <TouchableOpacity
                style={[
                  styles.vehicleButton,
                  selectedVehicle === "van" && styles.selectedVehicle,
                  styles.vanButton,
                ]}
                onPress={() => setSelectedVehicle("van")}
              >
                <Link href="/userScheduleView">
                  <Text style={styles.vehicleText}>🚐 Van</Text>
                </Link>
              </TouchableOpacity>

              <TouchableOpacity
                style={[
                  styles.vehicleButton,
                  selectedVehicle === "jeep" && styles.selectedVehicle,
                  styles.jeepButton,
                ]}
                onPress={() => setSelectedVehicle("jeep")}
              >
                <Text style={styles.vehicleText}>🚗 Jeep</Text>
              </TouchableOpacity>
            </View>
          </View>

          {/* Destination Section */}
          <View style={styles.section}>
            <Text style={styles.sectionTitle}>Destination:</Text>

            {/* Route Cards */}

            <View style={styles.routeCards}>
              <RouteCard from="Maasin" to="Bato" />
              <RouteCard from="Maasin" to="Bay-bay" />
              <RouteCard from="Maasin" to="Bato" />
            </View>
          </View>
        </ScrollView>
      </SafeAreaView>
    </LinearGradient>
  );
}

const RouteCard = ({ from, to }) => {
  return (
    <LinearGradient
      colors={["rgb(169, 205, 216)", "rgb(129, 177, 119)"]}
      start={{ x: 0, y: 0 }}
      end={{ x: 1, y: 1 }}
      style={styles.routeCard}
    >
      <View style={styles.routeIconColumn}>
        <View style={styles.routeLine}></View>
        <View style={styles.arrowContainer}>
          <Text style={styles.arrowUp}>↑ </Text>
          <Text style={styles.arrowDown}> ↓</Text>
        </View>
        <View style={styles.routeLine}></View>
      </View>

      <View style={styles.routeInfoColumn}>
        <View style={styles.routeInfo}>
          <Ionicons name="navigate-circle-outline" size={18} color="#fff" />
          <Text style={styles.routeLabel}>From:</Text>
          <Text style={styles.routeValue}>{from}</Text>
        </View>

        <View style={styles.routeInfo}>
          <Ionicons name="location-outline" size={18} color="#fff" />
          <Text style={styles.routeLabel}>To:</Text>
          <Text style={styles.routeValue}>{to}</Text>
        </View>
      </View>

      <View style={styles.tripTypeColumn}>
        <View style={styles.tripTypeButton}>
          <Text style={styles.tripTypeText}>One Way</Text>
        </View>
      </View>
    </LinearGradient>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  safeArea: {
    flex: 1,
    paddingTop: 40,
  },
  menuContainer: {
    position: "absolute",
    top: 40,
    right: 20,
    zIndex: 10,
  },

  loginContainer: {
    position: "absolute",
    top: 39,
    right: 20,
    zIndex: 10,
  },
  menuIcon: {
    padding: 5,
  },
  menuLine: {
    width: 24,
    height: 2,
    backgroundColor: "#555",
    marginVertical: 3,
  },
  scrollContent: {
    paddingBottom: 40,
    paddingTop: 40,
  },
  headerBanner: {
    backgroundColor: "#fff",
    marginHorizontal: 20,
    marginTop: 40,
    marginBottom: 20,
    padding: 15,
    borderRadius: 20,
    shadowColor: "#000",
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.2,
    shadowRadius: 4,
    elevation: 5,
    alignItems: "center",
  },
  headerText: {
    fontSize: 24,
    fontWeight: "600",
    color: "#555",
  },
  section: {
    marginVertical: 10,
    paddingHorizontal: 20,
  },
  sectionTitle: {
    fontSize: 20,
    fontWeight: "600",
    color: "#555",
    marginBottom: 10,
  },
  vehiclesContainer: {
    flexDirection: "row",
    justifyContent: "space-between",
  },
  vehicleButton: {
    padding: 15,
    borderRadius: 20,
    width: "30%",
    alignItems: "center",
    shadowColor: "#000",
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.2,
    shadowRadius: 3,
    elevation: 3,
  },
  busButton: {
    backgroundColor: "#8be3c9",
  },
  vanButton: {
    backgroundColor: "#b5c1c1",
  },
  jeepButton: {
    backgroundColor: "#c9a6db",
  },
  selectedVehicle: {
    borderWidth: 2,
    borderColor: "#3aa88d",
  },
  vehicleText: {
    fontSize: 16,
    fontWeight: "500",
  },
  routeCards: {
    marginVertical: 10,
  },
  routeCard: {
    backgroundColor: "#e57b9b",
    borderRadius: 20,
    padding: 15,
    marginBottom: 15,
    flexDirection: "row",
    shadowColor: "#000",
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.2,
    shadowRadius: 3,
    elevation: 3,
  },
  routeIconColumn: {
    width: 30,
    alignItems: "center",
    justifyContent: "space-between",
  },
  routeLine: {
    width: 2,
    height: 20,
    backgroundColor: "#fff",
  },
  arrowContainer: {
    alignItems: "center",
  },
  arrowUp: {
    color: "#fff",
    fontSize: 18,
    lineHeight: 18,
  },
  arrowDown: {
    color: "#fff",
    fontSize: 18,
    lineHeight: 18,
  },
  routeInfoColumn: {
    flex: 1,
    paddingLeft: 10,
    justifyContent: "center",
  },
  routeInfo: {
    flexDirection: "row",
    alignItems: "center",
    marginVertical: 5,
  },
  routeLabel: {
    color: "#fff",
    marginRight: 5,
    fontSize: 16,
  },
  routeValue: {
    color: "#ffea80",
    fontWeight: "bold",
    fontSize: 16,
  },
  tripTypeColumn: {
    justifyContent: "center",
    alignItems: "flex-end",
    paddingLeft: 10,
  },
  tripTypeButton: {
    backgroundColor: "#70e1d0",
    paddingVertical: 6,
    paddingHorizontal: 12,
    borderRadius: 15,
  },
  tripTypeText: {
    color: "#333",
    fontWeight: "500",
  },
});
