import React, {useState} from 'react';
import { LinearGradient } from 'expo-linear-gradient';
import { View, Text, StyleSheet } from 'react-native';

export default function Login() {
  return (
    <LinearGradient
      colors={['#ff7e5f', '#feb47b']} // Gradient colors
      style={styles.container}
    >
      <Text style={styles.text}>Hello, Expo!</Text>
    </LinearGradient>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  text: {
    color: '#fff',
    fontSize: 24,
  },
});
