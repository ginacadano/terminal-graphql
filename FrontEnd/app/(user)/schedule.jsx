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

export default function Schedule() {
  const [selectedSchedule, setSelectedSchedule] = useState(null);
  const [isAddModalVisible, setIsAddModalVisible] = useState(false);

  // Mock schedule data for UI purposes
  const mockSchedules = [
    {
      schedule_id: 1,
      date: "2025-04-28",
      plate_no: "ABC123",
      departure_time: "08:00 AM",
      arrival_time: "10:00 AM",
      destination: "Maasin to Bato",
    },
    {
      schedule_id: 2,
      date: "2025-04-29",
      plate_no: "XYZ789",
      departure_time: "02:00 PM",
      arrival_time: "04:00 PM",
      destination: "Maasin to Bay-bay",
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
              <Text style={styles.menuText}>Login</Text>
            </Link>
          </TouchableOpacity>
        </View>

        {/* Main Content */}
        <ScrollView contentContainerStyle={styles.scrollContent}>
          {/* Header Banner */}
          <View style={styles.headerBanner}>
            <Text style={styles.headerText}>Schedule Management</Text>
          </View>

          {/* Schedule List */}
          <View style={styles.section}>
            <Text style={styles.sectionTitle}>Schedules:</Text>
            <View style={styles.scheduleContainer}>
              {mockSchedules.map((schedule) => (
                <ScheduleCard
                  key={schedule.schedule_id}
                  schedule={schedule}
                  isSelected={selectedSchedule === schedule.schedule_id}
                  onSelect={() => setSelectedSchedule(schedule.schedule_id)}
                />
              ))}
            </View>
          </View>

          {/* Add Schedule Button */}
          <TouchableOpacity
            style={styles.addButton}
            onPress={() => setIsAddModalVisible(true)}
          >
            <Text style={styles.addButtonText}>Add New Schedule</Text>
          </TouchableOpacity>

          {/* Add Schedule Modal (Simplified) */}
          {isAddModalVisible && (
            <View style={styles.modalContainer}>
              <LinearGradient
                colors={["rgb(169, 205, 216)", "rgb(129, 177, 119)"]}
                start={{ x: 0, y: 0 }}
                end={{ x: 1, y: 1 }}
                style={styles.modalContent}
              >
                <Text style={styles.modalTitle}>Add Schedule</Text>
                <TextInput
                  style={styles.input}
                  placeholder="Date (YYYY-MM-DD)"
                  placeholderTextColor="#aaa"
                />
                <TextInput
                  style={styles.input}
                  placeholder="Plate Number"
                  placeholderTextColor="#aaa"
                />
                <TextInput
                  style={styles.input}
                  placeholder="Departure Time (HH:MM AM/PM)"
                  placeholderTextColor="#aaa"
                />
                <TextInput
                  style={styles.input}
                  placeholder="Arrival Time (HH:MM AM/PM)"
                  placeholderTextColor="#aaa"
                />
                <TextInput
                  style={styles.input}
                  placeholder="Destination"
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

const ScheduleCard = ({ schedule, isSelected, onSelect }) => {
  return (
    <LinearGradient
      colors={["rgb(169, 205, 216)", "rgb(129, 177, 119)"]}
      start={{ x: 0, y: 0 }}
      end={{ x: 1, y: 1 }}
      style={[styles.scheduleCard, isSelected && styles.selectedSchedule]}
    >
      <TouchableOpacity onPress={onSelect}>
        <View style={styles.scheduleInfo}>
          <Ionicons
            name="calendar-outline"
            size={18}
            color="#fff"
            style={styles.icon}
          />
          <View>
            <Text style={styles.scheduleLabel}>Date:</Text>
            <Text style={styles.scheduleValue}>{schedule.date}</Text>
          </View>
        </View>
        <View style={styles.scheduleInfo}>
          <Ionicons
            name="car-outline"
            size={18}
            color="#fff"
            style={styles.icon}
          />
          <View>
            <Text style={styles.scheduleLabel}>Plate No:</Text>
            <Text style={styles.scheduleValue}>{schedule.plate_no}</Text>
          </View>
        </View>
        <View style={styles.scheduleInfo}>
          <Ionicons
            name="time-outline"
            size={18}
            color="#fff"
            style={styles.icon}
          />
          <View>
            <Text style={styles.scheduleLabel}>Departure:</Text>
            <Text style={styles.scheduleValue}>{schedule.departure_time}</Text>
          </View>
        </View>
        <View style={styles.scheduleInfo}>
          <Ionicons
            name="time-outline"
            size={18}
            color="#fff"
            style={styles.icon}
          />
          <View>
            <Text style={styles.scheduleLabel}>Arrival:</Text>
            <Text style={styles.scheduleValue}>{schedule.arrival_time}</Text>
          </View>
        </View>
        <View style={styles.scheduleInfo}>
          <Ionicons
            name="location-outline"
            size={18}
            color="#fff"
            style={styles.icon}
          />
          <View>
            <Text style={styles.scheduleLabel}>Destination:</Text>
            <Text style={styles.scheduleValue}>{schedule.destination}</Text>
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
  scheduleContainer: {
    marginVertical: 10,
  },
  scheduleCard: {
    borderRadius: 20,
    padding: 15,
    marginBottom: 15,
    shadowColor: "#000",
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.2,
    shadowRadius: 3,
    elevation: 3,
  },
  selectedSchedule: {
    borderWidth: 2,
    borderColor: "#3aa88d",
  },
  scheduleInfo: {
    flexDirection: "row",
    alignItems: "center",
    marginVertical: 5,
  },
  icon: {
    marginRight: 10,
  },
  scheduleLabel: {
    color: "#fff",
    fontSize: 16,
  },
  scheduleValue: {
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