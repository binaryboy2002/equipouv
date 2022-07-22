mqttClient=mqttclient("tcp://test.mosquitto.org",ClientID="micliente",Port=1883);
topicToWrite = "equipouv/javierjesusluis/valor3"
msg = "1";
write(mqClient, topicToWrite, msg);