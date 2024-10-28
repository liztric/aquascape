#include <Arduino.h>
#include <WiFi.h>
#include <Firebase_ESP_Client.h>
#include <OneWire.h>
#include <DallasTemperature.h>
#include <Wire.h>
#include <LiquidCrystal_I2C.h>
#include "addons/TokenHelper.h"

#define WIFI_SSID "XLXL"
#define WIFI_PASSWORD "11223344"
#define API_KEY "AIzaSyBgD_196K9e0NmyVbGtHxlyVAdgpGu5Yyo"
#define DATABASE_URL "https://aquascape-ffef6-default-rtdb.asia-southeast1.firebasedatabase.app/"
#define PH_SENSOR_PIN 34
#define ONE_WIRE_BUS 4

// Pin relay untuk kontrol lampu dan kipas
#define RELAY_LED_PIN 14  // Lampu
#define RELAY_FAN_PIN 12   // Kipas

// Pin untuk RGB LED
#define RED_PIN 27
#define GREEN_PIN 26
#define BLUE_PIN 25

FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig config;

OneWire oneWire(ONE_WIRE_BUS);
DallasTemperature sensors(&oneWire);

LiquidCrystal_I2C lcd(0x27, 20, 4);

float PH4 = 3.2992;
float PH9 = 2.7856;
int nilai_analog_PH;
double TeganganPh;
float Po = 0;
float PH_step;

unsigned long sendDataPrevMillis = 0;
bool signupOK = false;

// Status LED dan Fan
bool ledStatus = false;
bool fanStatus = false;

// Fungsi untuk menghubungkan ke Wi-Fi
void connectToWiFi() {
    WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
    Serial.print("Menghubungkan ke Wi-Fi");
    lcd.setCursor(0, 2);
    lcd.print("Menghubungkan wifi..");

    int attempts = 0;
    while (WiFi.status() != WL_CONNECTED && attempts < 10) {
        Serial.print(".");
        delay(300);
        attempts++;
    }

    if (WiFi.status() != WL_CONNECTED) {
        Serial.println("\nGagal terhubung ke Wi-Fi. Harap periksa kredensial Anda.");
        while (true);
    } else {
        Serial.println("\nTerhubung dengan IP: " + WiFi.localIP().toString());
        lcd.clear();
    }
}

// Fungsi untuk menangani koneksi Firebase
void handleFirebaseConnection() {
    if (Firebase.signUp(&config, &auth, "", "")) {
        signupOK = true;
        Firebase.begin(&config, &auth);
        Firebase.reconnectWiFi(true);
    } else {
        Serial.printf("Kesalahan Pendaftaran Firebase: %s\n", config.signer.signupError.message.c_str());
        delay(5000);
        handleFirebaseConnection();
    }
}

// Fungsi untuk memperbarui status relay dari Firebase
void updateRelayStatus() {
    // Membaca status dari Firebase untuk LED
    if (Firebase.RTDB.getBool(&fbdo, "relays/led")) {
        ledStatus = fbdo.boolData();
        digitalWrite(RELAY_LED_PIN, ledStatus ? HIGH : LOW);  // Kontrol relay untuk lampu
        Serial.println(ledStatus ? "Lampu HIDUP" : "Lampu MATI");
    } else {
        Serial.println("Gagal mendapatkan status lampu dari Firebase.");
    }

    // Membaca status dari Firebase untuk Fan
    if (Firebase.RTDB.getBool(&fbdo, "relays/fan")) {
        fanStatus = fbdo.boolData();
        digitalWrite(RELAY_FAN_PIN, fanStatus ? HIGH : LOW);  // Kontrol relay untuk kipas
        Serial.println(fanStatus ? "Kipas HIDUP" : "Kipas MATI");
    } else {
        Serial.println("Gagal mendapatkan status kipas dari Firebase.");
    }
}

// Fungsi untuk mengatur warna RGB LED berdasarkan suhu
void setRGBColor(float temperature) {
    if (temperature < 20) { // Suhu rendah (biru)
        analogWrite(RED_PIN, 0);
        analogWrite(GREEN_PIN, 0);
        analogWrite(BLUE_PIN, 255);
    } else if (temperature >= 20 && temperature < 32) { // Suhu sedang (hijau)
        analogWrite(RED_PIN, 0);
        analogWrite(GREEN_PIN, 255);
        analogWrite(BLUE_PIN, 0);
    } else { // Suhu sangat tinggi (merah)
        analogWrite(RED_PIN, 255);
        analogWrite(GREEN_PIN, 0);
        analogWrite(BLUE_PIN, 0);
    }
}

// Fungsi untuk menampilkan data di LCD dengan format yang lebih rapi
void displayData(int temperature, int pH, bool ledStatus, bool fanStatus) {
    lcd.clear();

    // Menampilkan suhu dengan simbol derajat
    lcd.setCursor(0, 0);
    lcd.print("Suhu :");
    lcd.print(temperature);
    lcd.write(0xDF); // Display degree symbol
    lcd.print("C"); // Menambahkan spasi untuk membersihkan sisa karakter

    // Menampilkan pH
    lcd.setCursor(0, 1);
    lcd.print("pH   : ");
    lcd.print(pH);
    lcd.print("     "); // Menambahkan spasi untuk membersihkan sisa karakter

    // Menampilkan status lampu
    lcd.setCursor(0, 2);
    lcd.print("Lampu: ");
    lcd.print(ledStatus ? "ON  " : "OFF ");
    
    // Menampilkan status kipas
    lcd.setCursor(0, 3);
    lcd.print("Kipas: ");
    lcd.print(fanStatus ? "ON  " : "OFF ");

    delay(2000); // Delay untuk melihat data
}

// Fungsi setup
void setup() {
    Serial.begin(115200);
    
    pinMode(PH_SENSOR_PIN, INPUT);
    
    // Inisialisasi relay
    pinMode(RELAY_LED_PIN, OUTPUT);
    pinMode(RELAY_FAN_PIN, OUTPUT);
    digitalWrite(RELAY_LED_PIN, LOW);  // Matikan lampu saat startup
    digitalWrite(RELAY_FAN_PIN, LOW);  // Matikan kipas saat startup

    // Inisialisasi RGB LED
    pinMode(RED_PIN, OUTPUT);
    pinMode(GREEN_PIN, OUTPUT);
    pinMode(BLUE_PIN, OUTPUT);
    
    // Inisialisasi LCD
    lcd.init();
    lcd.backlight();

    // Menampilkan judul dengan animasi geser
    String title = " --Smart Aquascape--";
    int titleLength = title.length();

    for (int i = 0; i < titleLength; i++) {
        lcd.clear();
        lcd.setCursor(0, 0);
        lcd.print(title.substring(i, titleLength) + title.substring(0, i)); // Geser teks
        delay(300); // Delay untuk efek animasi
    }

   // Pesan selamat datang
    lcd.clear();
    String welcomeLine1 = "  Selamat datang  "; // Added spaces for better centering
    String welcomeLine2 = "  Smart Aquascape!   "; // Added spaces for better centering

    lcd.setCursor((20 - welcomeLine1.length()) / 2, 0); // Centering the first line
    lcd.print(welcomeLine1);
    lcd.setCursor((20 - welcomeLine2.length()) / 2, 1); // Centering the second line
    lcd.print(welcomeLine2);
    delay(2000);
    lcd.clear();



    connectToWiFi();

    config.api_key = API_KEY;
    config.database_url = DATABASE_URL;
    config.token_status_callback = tokenStatusCallback;

    handleFirebaseConnection();

    sensors.begin();
}

// Fungsi loop
void loop() {
    if (Firebase.ready() && signupOK && (millis() - sendDataPrevMillis > 2000 || sendDataPrevMillis == 0)) {
        sendDataPrevMillis = millis();
        
        // Membaca dan menampilkan nilai pH
        nilai_analog_PH = analogRead(PH_SENSOR_PIN);
        TeganganPh = 3.3 / 4096.0 * nilai_analog_PH;
        PH_step = (PH4 - PH9) / 5.17;
        Po = 7.00 + ((PH9 - TeganganPh) / PH_step);

        Serial.print("Nilai ADC PH = ");
        Serial.println(nilai_analog_PH);
        Serial.print("TeganganPh = ");
        Serial.println(TeganganPh, 3);
        Serial.print("Nilai PH cairan = ");
        Serial.println(Po, 2);

        // Membaca suhu dari sensor DS18B20
        sensors.requestTemperatures();
        float temperature = sensors.getTempCByIndex(0);

        // Set RGB color based on temperature
        setRGBColor(temperature);

        // Perbarui status relay lampu dan kipas
        updateRelayStatus();

        // Convert temperature and pH to integers
        int tempInt = static_cast<int>(temperature);
        int pHInt = static_cast<int>(Po);

        // Menampilkan data di LCD
        displayData(tempInt, pHInt, ledStatus, fanStatus);

        // Kirim data ke Firebase
        bool dataSent = false;
        int retryCount = 0;

        while (!dataSent && retryCount < 3) {
            if (Firebase.RTDB.setInt(&fbdo, "sensors/ph", pHInt) &&
                Firebase.RTDB.setInt(&fbdo, "sensors/temperature", tempInt)) {
                Serial.println("Nilai pH dan suhu telah dikirim ke Firebase.");
                dataSent = true;
            } else {
                Serial.println("GAGAL mengirim data. Alasan: " + fbdo.errorReason());
                retryCount++;
                delay(1000);
            }
        }

        delay(3000);
    }
}
