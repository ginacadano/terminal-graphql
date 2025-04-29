import React, { useState } from "react";
import {
  Text,
  View,
  StyleSheet,
  TouchableOpacity,
  SafeAreaView,
  ScrollView,
  TextInput,
} from "react-native";
import { Ionicons } from "@expo/vector-icons";
import { LinearGradient } from "expo-linear-gradient";
import { Link } from "expo-router";

export default function Vehicle() {
  const [selectedVehicle, setSelectedVehicle] = useState(null);
  const [isAddModalVisible, setIsAddModalVisible] = useState(false);

  // Mock vehicle data for UI purposes
  const mockVehicles = [
    {
      vehicle_id: 1,
      plate_no: "ABC123",
      capacity: 50,
      categories: "Bus",
      driver_name: "John Doe",
      contact_no: "09123456789",
      vehicle_name: "City Cruiser",
    },
    {
      vehicle_id: 2,
      plate_no: "XYZ789",
      capacity: 15,
      categories: "Van",
      driver_name: "Jane Smith",
      contact_no: "09876543210",
      vehicle_name: "Travel Mate",
    },
  ];

  return (
    <LinearGradient
      colors={["#a1f4ff", "#c9b6e4", "#a0c7c7"]}
      style={styles.container}
    >
      <SafeAreaView style={styles.safeArea}>
        {/* Menu/Login */}
        <View style={styles.menuContainer}>
          <TouchableOpacity>
            <Link href="/login">
              <Text style={styles.menuText}>Log-out</Text>
            </Link>
          </TouchableOpacity>
        </View>

        {/* Main Content */}
        <ScrollView contentContainerStyle={styles.scrollContent}>
          {/* Header Banner */}
          <View style={styles.headerBanner}>
            <Text style={styles.headerText}>Vehicle Management</Text>
          </View>

          {/* Vehicle List */}
          <View style={styles.section}>
            <Text style={styles.sectionTitle}>Vehicles:</Text>
            <View style={styles.vehicleContainer}>
              {mockVehicles.map((vehicle) => (
                <VehicleCard
                  key={vehicle.vehicle_id}
                  vehicle={vehicle}
                  isSelected={selectedVehicle === vehicle.vehicle_id}
                  onSelect={() => setSelectedVehicle(vehicle.vehicle_id)}
                />
              ))}
            </View>
          </View>

          {/* Add Vehicle Button */}
          <TouchableOpacity
            style={styles.addButton}
            onPress={() => setIsAddModalVisible(true)}
          >
            <Text style={styles.addButtonText}>Add New Vehicle</Text>
          </TouchableOpacity>

          {/* Add Vehicle Modal (Simplified) */}
          {isAddModalVisible && (
            <View style={styles.modalContainer}>
              <LinearGradient
                colors={["rgb(169, 205, 216)", "rgb(129, 177, 119)"]}
                start={{ x: 0, y: 0 }}
                end={{ x: 1, y: 1 }}
                style={styles.modalContent}
              >
                <Text style={styles.modalTitle}>Add Vehicle</Text>
                <TextInput
                  style={styles.input}
                  placeholder="Plate Number"
                  placeholderTextColor="#aaa"
                />
                <TextInput
                  style={styles.input}
                  placeholder="Capacity"
                  placeholderTextColor="#aaa"
                  keyboardType="numeric"
                />
                <TextInput
                  style={styles.input}
                  placeholder="Category (e.g., Bus, Van)"
                  placeholderTextColor="#aaa"
                />
                <TextInput
                  style={styles.input}
                  placeholder="Driver Name"
                  placeholderTextColor="#aaa"
                />
                <TextInput
                  style={styles.input}
                  placeholder="Contact Number"
                  placeholderTextColor="#aaa"
                  keyboardType="phone-pad"
                />
                <TextInput
                  style={styles.input}
                  placeholder="Vehicle Name"
                  placeholderTextColor="#aaa"
                />
                <View style={styles.modalButtons}>
                  <TouchableOpacity
                    style={styles.modalButton}
                    onPress={() => setIsAddModalVisible(false)}
                  >
                    <Text style={styles.modalButtonText}>Cancel</Text>
                  </TouchableOpacity>
                  <TouchableOpacity style={styles.modalButton}>
                    <Text style={styles.modalButtonText}>Submit</Text>
                  </TouchableOpacity>
                </View>
              </LinearGradient>
            </View>
          )}
        </ScrollView>
      </SafeAreaView>
    </LinearGradient>
  );
}

const VehicleCard = ({ vehicle, isSelected, onSelect }) => {
  return (
    <LinearGradient
      colors={["rgb(169, 205, 216)", "rgb(129, 177, 119)"]}
      start={{ x: 0, y: 0 }}
      end={{ x: 1, y: 1 }}
      style={[styles.vehicleCard, isSelected && styles.selectedVehicle]}
    >
      <TouchableOpacity onPress={onSelect}>
        <View style={styles.vehicleInfo}>
          <Ionicons
            name="car-outline"
            size={18}
            color="#fff"
            style={styles.icon}
          />
          <View>
            <Text style={styles.vehicleLabel}>Plate No:</Text>
            <Text style={styles.vehicleValue}>{vehicle.plate_no}</Text>
          </View>
        </View>
        <View style={styles.vehicleInfo}>
          <Ionicons
            name="people-outline"
            size={18}
            color="#fff"
            style={styles.icon}
          />
          <View>
            <Text style={styles.vehicleLabel}>Capacity:</Text>
            <Text style={styles.vehicleValue}>{vehicle.capacity}</Text>
          </View>
        </View>
        <View style={styles.vehicleInfo}>
          <Ionicons
            name="bus-outline"
            size={18}
            color="#fff"
            style={styles.icon}
          />
          <View>
            <Text style={styles.vehicleLabel}>Category:</Text>
            <Text style={styles.vehicleValue}>{vehicle.categories}</Text>
          </View>
        </View>
        <View style={styles.vehicleInfo}>
          <Ionicons
            name="person-outline"
            size={18}
            color="#fff"
            style={styles.icon}
          />
          <View>
            <Text style={styles.vehicleLabel}>Driver:</Text>
            <Text style={styles.vehicleValue}>{vehicle.driver_name}</Text>
          </View>
        </View>
        <View style={styles.vehicleInfo}>
          <Ionicons
            name="call-outline"
            size={18}
            color="#fff"
            style={styles.icon}
          />
          <View>
            <Text style={styles.vehicleLabel}>Contact:</Text>
            <Text style={styles.vehicleValue}>{vehicle.contact_no}</Text>
          </View>
        </View>
        <View style={styles.vehicleInfo}>
          <Ionicons
            name="car-sport-outline"
            size={18}
            color="#fff"
            style={styles.icon}
          />
          <View>
            <Text style={styles.vehicleLabel}>Name:</Text>
            <Text style={styles.vehicleValue}>{vehicle.vehicle_name}</Text>
          </View>
        </View>
        <View style={styles.actionContainer}>
          <TouchableOpacity style={styles.actionButton}>
            <Text style={styles.actionText}>Edit</Text>
          </TouchableOpacity>
          <TouchableOpacity style={styles.actionButton}>
            <Text style={styles.actionText}>Delete</Text>
          </TouchableOpacity>
        </View>
      </TouchableOpacity>
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
  menuText: {
    fontSize: 16,
    color: "#555",
    fontWeight: "500",
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
  vehicleContainer: {
    marginVertical: 10,
  },
  vehicleCard: {
    borderRadius: 20,
    padding: 15,
    marginBottom: 15,
    shadowColor: "#000",
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.2,
    shadowRadius: 3,
    elevation: 3,
  },
  selectedVehicle: {
    borderWidth: 2,
    borderColor: "#3aa88d",
  },
  vehicleInfo: {
    flexDirection: "row",
    alignItems: "center",
    marginVertical: 5,
  },
  icon: {
    marginRight: 10,
  },
  vehicleLabel: {
    color: "#fff",
    fontSize: 16,
  },
  vehicleValue: {
    color: "#ffea80",
    fontWeight: "bold",
    fontSize: 16,
  },
  actionContainer: {
    flexDirection: "row",
    justifyContent: "flex-end",
    marginTop: 10,
  },
  actionButton: {
    backgroundColor: "#70e1d0",
    paddingVertical: 6,
    paddingHorizontal: 12,
    borderRadius: 15,
    marginLeft: 10,
  },
  actionText: {
    color: "#333",
    fontWeight: "500",
  },
  addButton: {
    backgroundColor: "#8be3c9",
    padding: 15,
    borderRadius: 20,
    marginHorizontal: 20,
    alignItems: "center",
    shadowColor: "#000",
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.2,
    shadowRadius: 3,
    elevation: 3,
  },
  addButtonText: {
    fontSize: 16,
    fontWeight: "500",
    color: "#333",
  },
  modalContainer: {
    ...StyleSheet.absoluteFillObject,
    backgroundColor: "rgba(0, 0, 0, 0.5)",
    justifyContent: "center",
    alignItems: "center",
  },
  modalContent: {
    backgroundColor: "#fff",
    marginHorizontal: 20,
    padding: 20,
    borderRadius: 20,
    width: "90%",
  },
  modalTitle: {
    fontSize: 20,
    fontWeight: "600",
    color: "#555",
    marginBottom: 20,
    textAlign: "center",
  },
  input: {
    backgroundColor: "#f0f0f0",
    borderRadius: 10,
    padding: 10,
    marginVertical: 10,
    fontSize: 16,
    color: "#333",
  },
  modalButtons: {
    flexDirection: "row",
    justifyContent: "space-between",
    marginTop: 20,
  },
  modalButton: {
    backgroundColor: "#70e1d0",
    paddingVertical: 10,
    paddingHorizontal: 20,
    borderRadius: 15,
  },
  modalButtonText: {
    color: "#333",
    fontWeight: "500",
    fontSize: 16,
  },
});
