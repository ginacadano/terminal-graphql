import { Tabs } from "expo-router";
import MaterialIcons from '@expo/vector-icons/MaterialIcons';

export default function TabsLayout() {
  return (
    <Tabs options={{
      headerShown: false,
   
      tabBarActiveTintColor: 'black',
      tabBarInactiveTintColor: 'black',
      tabBarLabelStyle: {
        fontSize: 12,
        marginBottom: 5,
      },
      tabBarIconStyle: {
        marginBottom: 5,
      },
    }}>
      {/* Define your tabs here */}
      <Tabs.Screen name='index'
      
      options={{
        title:'Home',
        headerTitle:'Index',
        headerShown: false,
        tabBarIcon: ({ color }) => (
          <MaterialIcons name="home" size={24} color='black' />
        ),
      }}
/>
      <Tabs.Screen name='login'
      options={{
        title:'login',
        headerTitle:'Login',
        headerShown: false,
      }}
      />
    </Tabs> 
  );
}
