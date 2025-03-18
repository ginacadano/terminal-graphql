
// Import database connection pool helper
import { pool } from "../helpers/dbHelper.js";

// Define GraphQL resolvers for user-related queries and mutations
export const vehicleResolver = {
    
    // Query resolvers handle fetching user data
    Query: {
        // Fetch all users from the database
        vehicles: async () => {
            const client = await pool.connect();
            try {
                const query = {
                    text: "SELECT * FROM vehicles", // SQL query to get all users
                };
                const result = await client.query(query);
                console.log("Result:", result.rows);
                return result.rows; // Return the list of users
            } catch (err) {
                console.error("Error:", err);
                throw new Error("Failed to fetch users.");
            } finally {
                client.release(); // Release the database connection
            }
        },

        // Fetch a single user by ID
        vehicle: async (_, { id }) => {
            const client = await pool.connect();
            try {
                const query = {
                    text: "SELECT * FROM vehicles WHERE vehicle_id = $7", // SQL query with parameter
                    values: [id],
                };
                const result = await client.query(query);
                console.log("Result:", result.rows);
                return result.rows[0]; // Return the user object
            } catch (err) {
                console.error("Error:", err);
                throw new Error("Failed to fetch user.");
            } finally {
                client.release(); // Release the database connection
            }
        },
    },

    // Mutation resolvers handle modifying user data
    Mutation: {
        // Add a new user account
        addVehicle: async (_, { vehicles, admin_id }) => {
            console.log("Add User Input Details: ",vehicles, admin_id);
            const client = await pool.connect();
            
            try {

                let response = {
                    content: null,
                    type: "",
                    message: "",
                };

                // Call a PostgreSQL function to add a new user
                const query = {
                    text: "SELECT * FROM fn_admin_add_vehicle($1, $2, $3, $4, $5, $6, $7) AS result",
                    values: [admin_id, vehicles.capacity, vehicles.categories, vehicles.driver_name, vehicles.contact_no, vehicles.vehicle_name, vehicles.plate_no],
                };

                const result = await client.query(query);
                
                // Process the result and return appropriate response
                if (result && result.rows.length > 0) {
                    const res = result.rows[0].result;
                    console.log("Added user result: ", res);
                    if (res) {
                        response = {
                            content: res.content,
                            type: res.type,
                            message: res.message,
                        };
                    }
                }

                return response;
            } catch (err) {
                console.error("Error:", err);
                throw new Error("Failed to add user account.");
            } finally {
                await client.end(); // Close database connection
            }
        },

        // Update an existing user account
        updateVehicle: async (_, { admin_id, vehicle_id, vehicles }) => {
            const client = await pool.connect();
            try {

                let response = {
                    type: "",
                    message: "",
                };

                // Call a PostgreSQL function to update user details
                const query = {
                    text: "SELECT fn_admin_update_vehicle($1, $2, $3, $4, $5, $6, $7, $8 ) AS result",
                    values: [admin_id, vehicle_id, vehicles.plate_no, vehicles.capacity, vehicles.categories, vehicles.driver_name, vehicles.contact_no, vehicles.vehicle_name],
                };

                const result = await client.query(query);

                // Process the result and return appropriate response
                if (result && result.rows.length > 0) {
                    const res = result.rows[0].result;
                    console.log("Updated user result: ", res);
                    if (res) {
                        response = {
                            type: res.type,
                            message: res.message,
                        };
                    }
                }

                return response;
            } catch (err) {
                console.error("Error:", err);
                throw new Error("Failed to update user account.");
            } finally {
                await client.end(); // Close database connection
            }
        },

        // Delete a user account
        deleteVehicle: async (_, { admin_id, plate_no }) => {
            const client = await pool.connect();
            try {
                let response = {
                    type: "",
                    message: "",
                };

                // Call a PostgreSQL function to delete a user
                const query = {
                    text: "SELECT fn_admin_delete_vehicle($1, $2) AS result",
                    values: [admin_id, plate_no],
                };

                const result = await client.query(query);

                // Process the result and return appropriate response
                if (result && result.rows.length > 0) {
                    const res = result.rows[0].result;
                    console.log("Deleted user result: ", res);
                    if (res) {
                        response = {
                            type: res.type,
                            message: res.message,
                        };
                    }
                }
                return response;
            } catch (err) {
                console.error("Error:", err);
                throw new Error("Failed to delete user account.");
            } finally {
                await client.end(); // Close database connection
            }
        },
    },
};
