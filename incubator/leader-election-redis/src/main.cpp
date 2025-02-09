#include <iostream>
#include <fstream>
#include <chrono>
#include <thread>
#include <hiredis/hiredis.h>

using namespace std;

const string LOG_FILE = "/shared/leaders.log";
const int CHECK_INTERVAL = 2; // Check every 2 seconds
const float RENEWAL_THRESHOLD = 0.8; // Renew at 80% of lease expiration time

void logMessage(const string &message) {
    ofstream logFile(LOG_FILE, ios::app);
    if (logFile.is_open()) {
        logFile << message << endl;
        logFile.close();
    }
}

bool acquireLock(redisContext *redis, const string &leaderKey, const string &podName, int leaseTime) {
    redisReply *reply = (redisReply *)redisCommand(redis, "SET %s %s NX PX %d", leaderKey.c_str(), podName.c_str(), leaseTime * 1000);
    if (reply == nullptr) {
        cerr << "[ERROR] Redis command failed." << endl;
        return false;
    }

    bool success = reply->type == REDIS_REPLY_STATUS && string(reply->str) == "OK";
    freeReplyObject(reply);
    return success;
}

bool renewLock(redisContext *redis, const string &leaderKey, const string &podName, int leaseTime) {
    redisReply *reply = (redisReply *)redisCommand(redis, "GET %s", leaderKey.c_str());
    if (reply == nullptr || reply->type != REDIS_REPLY_STRING) {
        return false;
    }

    string currentLeader = reply->str;
    freeReplyObject(reply);

    // Renew lock only if we are still the leader
    if (currentLeader == podName) {
        redisReply *renewReply = (redisReply *)redisCommand(redis, "SET %s %s XX PX %d", leaderKey.c_str(), podName.c_str(), leaseTime * 1000);
        if (renewReply == nullptr) {
            cerr << "[ERROR] Redis renewal command failed." << endl;
            return false;
        }
        bool success = renewReply->type == REDIS_REPLY_STATUS && string(renewReply->str) == "OK";
        freeReplyObject(renewReply);
        return success;
    }
    return false;
}

string getLeader(redisContext *redis, const string &leaderKey) {
    redisReply *reply = (redisReply *)redisCommand(redis, "GET %s", leaderKey.c_str());
    if (reply == nullptr || reply->type != REDIS_REPLY_STRING) {
        return "";
    }

    string leader = reply->str;
    freeReplyObject(reply);
    return leader;
}

int main() {
    string redisHost = getenv("REDIS_HOST") ? getenv("REDIS_HOST") : "127.0.0.1";
    int redisPort = getenv("REDIS_PORT") ? stoi(getenv("REDIS_PORT")) : 6379;
    string leaderKey = getenv("LEADER_KEY") ? getenv("LEADER_KEY") : "leader";
    int leaseTime = getenv("LEASE_TIME") ? stoi(getenv("LEASE_TIME")) : 5;
    string podName = getenv("POD_NAME") ? getenv("POD_NAME") : "unknown";

    redisContext *redis = redisConnect(redisHost.c_str(), redisPort);
    if (redis == nullptr || redis->err) {
        cerr << "[ERROR] Failed to connect to Redis!" << endl;
        return 1;
    }

    cout << "[INFO] Connected to Redis. Pod Name: " << podName << endl;

    bool isLeader = false;
    int renewThreshold = leaseTime * RENEWAL_THRESHOLD;

    while (true) {
        string currentLeader = getLeader(redis, leaderKey);

        if (currentLeader == podName) {
            // Try to renew leadership before expiration
            if (renewLock(redis, leaderKey, podName, leaseTime)) {
                cout << "[INFO] Leadership renewed: " << podName << endl;
                logMessage("[LEADER] " + podName + " is writing logs.");
            } else {
                cout << "[ERROR] Failed to renew leadership! Another pod may take over." << endl;
                isLeader = false;
            }
        } else if (currentLeader.empty()) {
            // If no leader exists, attempt to acquire leadership
            if (acquireLock(redis, leaderKey, podName, leaseTime)) {
                cout << "[INFO] Acquired leadership: " << podName << endl;
                isLeader = true;
            }
        } else {
            if (isLeader) {
                cout << "[INFO] Leadership changed. New leader: " << currentLeader << endl;
                logMessage("[INFO] Leadership changed. New leader: " + currentLeader);
            }
            isLeader = false;
        }

        this_thread::sleep_for(chrono::seconds(renewThreshold));
    }

    redisFree(redis);
    return 0;
}
