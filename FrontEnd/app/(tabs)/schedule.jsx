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
import AntDesign from "@expo/vector-icons/AntDesign";
export default function Index() {
  const [selectedVehicle, setSelectedVehicle] = useState(null);

  return (
    <LinearGradient
      colors={["#a1f4ff", "#c9b6e4", "#a0c7c7"]}
      style={styles.container}
    >
      <SafeAreaView style={styles.safeArea}>
        <View style={styles.menuContainer}>
          <TouchableOpacity>
            <AntDesign name="logout" size={24} color="black" />
          </TouchableOpacity>
        </View>
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
    paddingTop: 40,
  },
  menuContainer: {
    position: "absolute",
    top: 40,
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
