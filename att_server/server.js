const express = require("express");
const bodyParser = require("body-parser");
const {
  authenticateUser,
  addAttendance,
  checkTodayLoginStatus,
  logout,
} = require("./services.js");
const cors = require("cors");

// Initialize Express app
const app = express();
const PORT = 3000;

// Middleware to parse incoming request bodies (JSON)
app.use(bodyParser.json());
app.use(cors());

// POST /auth route for user authentication
app.post("/auth", (req, res) => {
  const { email, password } = req.body;

  console.log("Called");

  // Authenticate user using the service
  const { isAuthenticated, data } = authenticateUser(email, password);

  console.log(isAuthenticated, data);

  if (isAuthenticated) {
    res.json({
      success: true,
      name: data["name"],
      id: data["id"],
      message: "Authentication successful",
    });
  } else {
    res.status(401).json({ success: false, message: "Invalid credentials" });
  }
});

// Import the new service function
const { getAllUsersHistory, getUserHistoryById } = require("./services.js");

// GET /history/all route to retrieve all users' history (ID and Name)
app.get("/history/all", (req, res) => {
  const users = getAllUsersHistory();
  res.json({ success: true, data: users });
});

// GET /history/all/:id route to retrieve a specific user's history except for the given ID
app.get("/history/all/:id", (req, res) => {
  console.log("Called");

  const { id } = req.params;
  const users = getUserHistoryById(id);

  console.log(id);

  if (users) {
    console.log(users);

    res.json({ success: true, data: users });
  } else {
    res.status(404).json({ success: false, message: "User not found" });
  }
});

// POST /get-status route to check today's login status
// POST /get-status route to check today's login status
app.post("/get-status", (req, res) => {
  const { id, date } = req.body;

  console.log("Checking login status for today");

  const { status, data } = checkTodayLoginStatus(id, date);

  res.json({ success: true, status, data: data });
});

// POST /add-attendance route to add attendance
app.post("/add-attendance", (req, res) => {
  const { id, date, day, time, duration, locationData } = req.body;

  console.log("Called");

  console.log(locationData);

  const attendanceRecord = {
    date: date,
    day: day,
    login_time: time,
    login_location: {
      lat: locationData.latitude, // Access latitude directly
      long: locationData.longitude, // Access longitude directly
    },
    logout_time: null,
    logout_location: null,
    duration: duration,
  };

  console.log(attendanceRecord);

  // Add attendance using the service
  const result = addAttendance(id, attendanceRecord);

  if (result.success) {
    res.json({ success: true, message: result.message });
  } else {
    res.status(404).json({ success: false, message: result.message });
  }
});
app.post("/logout-attendance", (req, res) => {
  const { id, date, time, locationData } = req.body;

  console.log("Called");

  console.log(locationData);

  const logout_record = {
    date: date,
    time: time,
    location: {
      lat: locationData.latitude, // Access latitude directly
      long: locationData.longitude, // Access longitude directly
    },
    // duration: duration,
  };

  // console.log(attendanceRecord);

  // Add attendance using the service
  const result = logout(id, logout_record);

  if (result.success) {
    res.json({ success: true, message: result.message });
  } else {
    res.status(404).json({ success: false, message: result.message });
  }
});

// Start the server
app.listen(PORT, () => {
  console.log(`Server is running on http://localhost:${PORT}`);
});
