const express = require('express');
const mongoose = require('mongoose');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const http = require('http');
const { Server } = require('socket.io');

const app = express();
const server = http.createServer(app);

const io = new Server(server, {
  cors: {
    origin: '*', // Allow all origins for development, refine in production
    methods: ['GET', 'POST'],
  }
});

app.use(express.json());

// MongoDB connection
mongoose.connect('mongodb://localhost:27017/flutter_chat_db', { useNewUrlParser: true, useUnifiedTopology: true })
    .then(() => console.log('Connected to MongoDB'))
    .catch((err) => console.error('MongoDB connection failed:', err));

// User Schema and Model
const userSchema = new mongoose.Schema({
  username: { type: String, required: true, unique: true },
  password: { type: String, required: true },
});

const User = mongoose.model('User', userSchema);

// Registration Endpoint
app.post('/register', async (req, res) => {
  const { username, password } = req.body;
  try {
    const hashedPassword = await bcrypt.hash(password, 10);
    const user = new User({ username, password: hashedPassword });
    await user.save();
    res.status(201).json({ message: 'User registered successfully' });
  } catch (err) {
    if (err.code === 11000) {
      return res.status(409).json({ message: 'Username already exists', error: err.message });
    }
    res.status(400).json({ message: 'Registration failed', error: err.message });
  }
});

// Login Endpoint
app.post('/login', async (req, res) => {
  const { username, password } = req.body;

  try {
    const user = await User.findOne({ username });
    if (!user) return res.status(401).json({ message: 'Invalid credentials' });
    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) return res.status(401).json({ message: 'Invalid credentials' });
    const token = jwt.sign({ username: user.username }, 'secret_key', { expiresIn: '1h' });
    res.json({ message: 'Login successful', token });
  } catch (err) {
    res.status(500).json({ message: 'Login failed', error: err.message });
  }
});

// Socket.IO Authentication Middleware
io.use((socket, next) => {
  const token = socket.handshake.auth.token; // Expects token in 'auth' object
  if (!token) {
    return next(new Error('Authentication error: No token provided'));
  }
  try {
    const decoded = jwt.verify(token, 'secret_key');
    socket.username = decoded.username; // Attach username to socket
    next();
  } catch (err) {
    next(new Error('Authentication error: Invalid token'));
  }
});

// Socket.IO Connection Handler
io.on('connection', (socket) => {
  console.log(`${socket.username} connected`);
  // Inform everyone a user joined
  io.emit('message', { username: 'System', message: `${socket.username} joined the chat.` });

  // Handle incoming 'message' events from clients
  socket.on('message', (data) => {
    // 'data' from client is already an object: {username: ..., message: ...}
    // We'll use the authenticated username from the socket for consistency
    const payload = {
      username: socket.username,
      message: data.message, // Access the 'message' property from client's data
    };
    console.log(`Message from ${payload.username}: ${payload.message}`);
    // Broadcast the message object to all connected clients
    io.emit('message', payload); // <--- Emit the object as expected by Flutter
  });

  // Handle client disconnect
  socket.on('disconnect', () => {
    console.log(`${socket.username} disconnected`);
    // Inform everyone a user left
    io.emit('message', { username: 'System', message: `${socket.username} left the chat.` });
  });
});

const PORT =  3000;
server.listen(PORT, () => {
  console.log(`Server is running on http://localhost:${PORT}`);
});