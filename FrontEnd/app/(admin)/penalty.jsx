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

export default function Penalty() {
  const [selectedPenalty, setSelectedPenalty] = useState(null);
  const [isAddModalVisible, setIsAddModalVisible] = useState(false);

  // Mock penalty data for UI purposes
  const mockPenalties = [
    {
      penalty_id: 1,
      violation: "Speeding",
      violation_date: "2025-04-20",
      amount_penalty: 500,
      plate_no: "ABC123",
      paid: false,
    },
    {
      penalty_id: 2,
      violation: "Illegal Parking",
      violation_date: "2025-04-22",
      amount_penalty: 300,
      plate_no: "XYZ789",
      paid: true,
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
            <Text style={styles.headerText}>Penalty Management</Text>
          </View>

          {/* Penalty List */}
          <View style={styles.section}>
            <Text style={styles.sectionTitle}>Penalties:</Text>
            <View style={styles.penaltyContainer}>
              {mockPenalties.map((penalty) => (
                <PenaltyCard
                  key={penalty.penalty_id}
                  penalty={penalty}
                  isSelected={selectedPenalty === penalty.penalty_id}
                  onSelect={() => setSelectedPenalty(penalty.penalty_id)}
                />
              ))}
            </View>
          </View>

          {/* Add Penalty Button */}
          <TouchableOpacity
            style={styles.addButton}
            onPress={() => setIsAddModalVisible(true)}
          >
            <Text style={styles.addButtonText}>Add New Penalty</Text>
          </TouchableOpacity>

          {/* Add Penalty Modal (Simplified) */}
          {isAddModalVisible && (
            <View style={styles.modalContainer}>
              <LinearGradient
                colors={["rgb(169, 205, 216)", "rgb(129, 177, 119)"]}
                start={{ x: 0, y: 0 }}
                end={{ x: 1, y: 1 }}
                style={styles.modalContent}
              >
                <Text style={styles.modalTitle}>Add Penalty</Text>
                <TextInput
                  style={styles.input}
                  placeholder="Violation"
                  placeholderTextColor="#aaa"
                />
                <TextInput
                  style={styles.input}
                  placeholder="Violation Date (YYYY-MM-DD)"
                  placeholderTextColor="#aaa"
                />
                <TextInput
                  style={styles.input}
                  placeholder="Amount"
                  placeholderTextColor="#aaa"
                  keyboardType="numeric"
                />
                <TextInput
                  style={styles.input}
                  placeholder="Plate Number"
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

const PenaltyCard = ({ penalty, isSelected, onSelect }) => {
  return (
    <LinearGradient
      colors={["rgb(169, 205, 216)", "rgb(129, 177, 119)"]}
      start={{ x: 0, y: 0 }}
      end={{ x: 1, y: 1 }}
      style={[styles.penaltyCard, isSelected && styles.selectedPenalty]}
    >
      <TouchableOpacity onPress={onSelect}>
        <View style={styles.penaltyInfo}>
          <Ionicons
            name="warning-outline"
            size={18}
            color="#fff"
            style={styles.icon}
          />
          <View>
            <Text style={styles.penaltyLabel}>Violation:</Text>
            <Text style={styles.penaltyValue}>{penalty.violation}</Text>
          </View>
        </View>
        <View style={styles.penaltyInfo}>
          <Ionicons
            name="calendar-outline"
            size={18}
            color="#fff"
            style={styles.icon}
          />
          <View>
            <Text style={styles.penaltyLabel}>Date:</Text>
            <Text style={styles.penaltyValue}>{penalty.violation_date}</Text>
          </View>
        </View>
        <View style={styles.penaltyInfo}>
          <Ionicons
            name="cash-outline"
            size={18}
            color="#fff"
            style={styles.icon}
          />
          <View>
            <Text style={styles.penaltyLabel}>Amount:</Text>
            <Text style={styles.penaltyValue}>₱{penalty.amount_penalty}</Text>
          </View>
        </View>
        <View style={styles.penaltyInfo}>
          <Ionicons
            name="car-outline"
            size={18}
            color="#fff"
            style={styles.icon}
          />
          <View>
            <Text style={styles.penaltyLabel}>Plate No:</Text>
            <Text style={styles.penaltyValue}>{penalty.plate_no}</Text>
          </View>
        </View>
        <View style={styles.statusContainer}>
          <Text
            style={[
              styles.statusText,
              penalty.paid ? styles.paid : styles.unpaid,
            ]}
          >
            {penalty.paid ? "Paid" : "Unpaid"}
          </Text>
          {!penalty.paid && (
            <TouchableOpacity style={styles.markPaidButton}>
              <Text style={styles.markPaidText}>Mark as Paid</Text>
            </TouchableOpacity>
          )}
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
  penaltyContainer: {
    marginVertical: 10,
  },
  penaltyCard: {
    borderRadius: 20,
    padding: 15,
    marginBottom: 15,
    shadowColor: "#000",
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.2,
    shadowRadius: 3,
    elevation: 3,
  },
  selectedPenalty: {
    borderWidth: 2,
    borderColor: "#3aa88d",
  },
  penaltyInfo: {
    flexDirection: "row",
    alignItems: "center",
    marginVertical: 5,
  },
  icon: {
    marginRight: 10,
  },
  penaltyLabel: {
    color: "#fff",
    fontSize: 16,
  },
  penaltyValue: {
    color: "#ffea80",
    fontWeight: "bold",
    fontSize: 16,
  },
  statusContainer: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
    marginTop: 10,
  },
  statusText: {
    fontSize: 14,
    fontWeight: "500",
  },
  paid: {
    color: "#70e1d0",
  },
  unpaid: {
    color: "#ff6b6b",
  },
  markPaidButton: {
    backgroundColor: "#70e1d0",
    paddingVertical: 6,
    paddingHorizontal: 12,
    borderRadius: 15,
  },
  markPaidText: {
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
