// Real device on the same WiFi → use the machine's LAN IP (current: 192.168.0.105)
// Android emulator → change back to http://10.0.2.2:3000/api
// Linux desktop → use http://localhost:3000/api
const String kApiBaseUrl = 'http://192.168.0.105:3000/api';
