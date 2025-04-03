import { StyleSheet } from 'react-native';

const index = StyleSheet.create({
    gradientContainer: {
        flex: 1, // Ensure it takes up the full screen height
        justifyContent: 'center', // Center the content vertically
        alignItems: 'center', // Center the content horizontally
      },
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: 'rgb(199, 133, 133)',
  },
  heading: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#333',
  },
  subheading: {
    fontSize: 18,
    color: '#555',
    marginTop: 10,
  },
});

export default index;