import { Tabs } from "expo-router";
import MaterialIcons from '@expo/vector-icons/MaterialIcons';

export default function TabsLayout() {
  return (
    <Tabs ScreenOptions={{
   
   tabBarStyle:{backgroundColor: 'white'},
      tabBarActiveTintColor: 'black',
      tabBarInactiveTintColor: 'gray',
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
        headerShown: false,
        tabBarIcon: ({ focused, color }) => (
          <MaterialIcons name="home" size={24} color={color} />
        ),
      }}
/>
      <Tabs.Screen name='login'
      options={{
        title:'login',
        headerShown: false,
        tabBarIcon: ({ focused, color }) => (
          <MaterialIcons name="menu" size={24} color={color} />
        ),
      }}
      />
    </Tabs> 
  );
}
