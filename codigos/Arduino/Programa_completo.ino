// Programa para la lectrua de las 4 variables
// Irradiancia, emperatura, Corriente y Voltaje 


String inputString = "";         // a String to hold incoming data
/// Sensores Análogicos de entrada
const int analog0 = A0;  
const int analog1 = A1;  
const int analog2 = A2;  
const int analog3 = A3;

 // Variable que almacenas los valores de los puertos análogicos
  
int sensor1 = 0;       
int sensor2 = 0;        
int sensor3 = 0;        
int sensor4 = 0;        

int LedV=13;             // Puerto de salida
int LedR=12;             // Puerto de salida

void setup() 
{
  Serial.begin(9600);
  pinMode(LedV, OUTPUT);
  pinMode(LedR, OUTPUT);
  inputString.reserve(10);          // reserve 200 bytes for the inputString:
}

void loop() {

  // Lectura de las variables
  // Sensor de Voltaje
 
  sensor1 = analogRead(analog0);   // Temperatura max 60 °C
  sensor2 = analogRead(analog1);   // Voltaje Maximo en DC=250 V
  sensor3 = analogRead(analog2);   // Corriente Maxima 8 A
  sensor4 = analogRead(analog3);   // Irradiancia Máxima es de 1100 W/m^2
  if (Serial.available() > 0) 
  {
    inputString=(char)Serial.read();
    if (inputString == "3")       // Solicitud de datos
    {   Serial.print(sensor1);
        Serial.print(":");
        Serial.print(sensor2);
        Serial.print(":");
        Serial.print(sensor3);
        Serial.print(":");
        Serial.println(sensor4);
        
  }
    
    if (inputString == "1")        // Encender Led Verde y Apagar Led rojo
    {
      digitalWrite(LedV, HIGH); 
      digitalWrite(LedR, LOW); 
    }
    if (inputString == "0")       // Apagar Led Verde y Endender Led rojo
    {
      digitalWrite(LedV, LOW);
      digitalWrite(LedR, HIGH); 
      
    }

 
}

}
