// Real device on the same WiFi → use the machine's LAN IP (run: ip addr show | grep "inet ")
// Android emulator → http://10.0.2.2:3000/api
// Linux desktop / Flutter web → http://localhost:3000/api
const String kApiBaseUrl = 'http://localhost:3000/api';
