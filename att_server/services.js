const fs = require("fs");
const path = require("path");

// Path to the data.json file
const dataFilePath = path.join(__dirname, "data.json");

// Read JSON file and parse data
const readData = () => {
  const rawData = fs.readFileSync(dataFilePath);
  return JSON.parse(rawData);
};

// Write updated data back to the JSON file
const writeData = (data) => {
  fs.writeFileSync(dataFilePath, JSON.stringify(data, null, 2));
};

// Authenticate user by email and password
const authenticateUser = (email, password) => {
  const users = readData();
  const user = users.find((u) => u.email === email && u.password === password);

  return { isAuthenticated: user ? true : false, data: user };
};

// Add attendance for a user by ID
const addAttendance = (id, attendanceRecord) => {
  const users = readData();
  const userIndex = users.findIndex((u) => u.id === id);

  if (userIndex !== -1) {
    // Push the attendance record into the user's attendance array
    users[userIndex].attendence.push(attendanceRecord);

    // Write the updated data back to the JSON file
    writeData(users);

    return { success: true, message: "Attendance added successfully" };
  } else {
    return { success: false, message: "User not found" };
  }
};
const logout = (id, logout_record) => {
  const users = readData();
  const userIndex = users.findIndex((u) => u.id === id);

  const TodayRecord = users[userIndex]["attendence"].find(
    (u) => u.date === logout_record.date
  );

  console.log(TodayRecord);

  if (TodayRecord) {
    // users[userIndex]["attendence"];
    TodayRecord.logout_time = logout_record.time;
    TodayRecord.logout_location = logout_record.location;
    // Write the updated data back to the JSON file
    writeData(users);

    return { success: true, message: "Attendance added successfully" };
  } else {
    return { success: false, message: "User not found" };
  }
};

// Add a function to check if today's attendance exists
const checkTodayLoginStatus = (id, date) => {
  const users = readData();
  const user = users.find((u) => u.id === id);

  if (user) {
    const todayAttendance = user.attendence.find(
      (record) => record.date === date
    );

    if (!todayAttendance) {
      // Case 1: No record found for today's date
      return { status: 0, data: null };
    } else if (todayAttendance.logout_time === null) {
      // Case 2: Login record found but logout_time is null
      return { status: 1, data: todayAttendance };
    } else {
      // Case 3: Both login and logout ktimes exist
      return { status: 2, data: todayAttendance };
    }
  } else {
    return { status: 4, data: null };
  }
};

// Retrieve all users' login history (returning ID and Name only)
const getAllUsersHistory = () => {
  const users = readData();

  // Map through users to return only ID and Name
  return users.map((user) => ({
    id: user.id,
    name: user.name,
    attendence: user.attendence, // You can include attendance data here or modify as needed
  }));
};

// Retrieve a specific user's login history by ID (excluding the given ID)
const getUserHistoryById = (id) => {
  const users = readData();

  // Filter out the user with the given ID
  const otherUsers = users.filter((user) => user.id === id);

  if (otherUsers.length > 0) {
    // Map through users to return ID, Name, and their attendance
    return otherUsers.map((user) => ({
      id: user.id,
      name: user.name,
      attendence: user.attendence,
    }));
  } else {
    return null;
  }
};

module.exports = {
  authenticateUser,
  getAllUsersHistory,
  getUserHistoryById,
  addAttendance,
  logout,
  checkTodayLoginStatus, // Export new function
};
