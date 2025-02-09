#include <iostream>
#include <fstream>
#include <string>
#include <thread>
#include <chrono>
#include <cstdlib>

const std::string LEADER_FILE = "/shared/leader.txt";  // Leader election file
const std::string LOG_FILE = "/shared/logs.txt";      // Shared log file

// Function to read leader from file
std::string getCurrentLeader() {
    std::ifstream file(LEADER_FILE);
    std::string leader;
    if (file.is_open()) {
        std::getline(file, leader);
        file.close();
    }
    return leader;
}

// Function to write log message to shared log file
void writeLog(const std::string& podName, const std::string& message) {
    std::ofstream logFile(LOG_FILE, std::ios::app); // Open in append mode
    if (logFile.is_open()) {
        logFile << "[POD: " << podName << "] " << message << std::endl;
        logFile.close();
    } else {
        std::cerr << "❌ Error: Could not open log file!" << std::endl;
    }
}

int main() {
    std::string podName = std::getenv("POD_NAME") ? std::getenv("POD_NAME") : "unknown-pod";

    while (true) {
        std::string leader = getCurrentLeader();

        if (leader == podName) {
            std::cout << "✅ I am the leader! Writing log..." << std::endl;
            writeLog(podName, "I am the leader and writing logs.");
        } else {
            std::cout << "🔹 I am a follower. Current leader: " << leader << std::endl;
            writeLog(podName, "I am a follower. Current leader: " + leader);
        }

        std::this_thread::sleep_for(std::chrono::seconds(5));
    }

    return 0;
}
