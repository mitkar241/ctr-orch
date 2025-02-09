# Leader Election using Lease API
---

## How Failover Works
- Normal Operation
  - Pods start, the kubectl sidecar polls the Lease API.
  - One pod wins the election and becomes the leader.
  - The leader pod writes its name to /shared/leader.txt.
  - The C++ app in the leader pod detects this and writes to the database.
- Leader Failure
  - The leader pod crashes or is deleted.
  - Lease expires in 15 seconds, and a new pod claims leadership.
  - The kubectl sidecar updates /shared/leader.txt with the new leader.
  - The new leader's C++ app detects this and starts writing to the database.
  - Total downtime: 1-2 seconds.

## Why This is the Best Approach
- Decouples C++ app from Kubernetes (no kubectl calls in C++).
- Uses Kubernetes-native Leader Election (Lease API).
- Failover is automatic and happens within seconds.
- Only one pod ever writes to the database at a time.
- Simple and efficient using a sidecar to manage Kubernetes state.

## Summary
- C++ app is completely independent of Kubernetes.
- Kubectl sidecar manages leader election and updates leader.txt.
- Failover is automatic and quick (1-2 seconds).
- Only the leader pod writes to the database.
- This setup ensures high availability with minimal downtime.

## Key Fixes
- RBAC Permissions Added → Sidecar can now update the Lease
- Lease Timeout Reduced → Speeds up failover detection
- More Frequent Leader Checks → New leader is chosen faster

## Features
- Uses kubectl to read and update the Lease object
- Acquires leadership if no leader exists
- Renews leadership periodically if the pod is already the leader
- Fails over to another pod if the leader dies
- Writes leader identity to /shared/leader.txt

## How It Works
- Checks the current leader from the Lease API
- If no leader exists, the pod acquires leadership
- If this pod is the leader, it renews leadership every few seconds
- If another pod is already the leader, it just waits and checks again
- Writes the current leader's name to /shared/leader.txt

## Expected Result
- my-app-1 or my-app-2 should take over leadership within 10 seconds
- kubectl get lease leader-election -n default -o yaml should show the updated holderIdentity and renewTime
- /shared/leader.txt should always contain the latest leader

## Improvements
- Add Liveness Probe → If kubectl-sidecar crashes, Kubernetes will restart it
- Monitor Failovers → Use kubectl logs to track leader changes
- Optimize Lease Duration → Adjust LEASE_DURATION for faster failovers

## Expected Result
- The renewTime field will now update correctly.
- Failover will work without errors.
- The leader election mechanism will run smoothly.

## Summary
- Fixed renewTime formatting → Now uses RFC3339Nano format
- Corrected date command → Includes microseconds
- Leader election will now work without errors

## Here's the improved leader election script that correctly:
- Reads leaseDurationSeconds and renewTime from the Lease API
- Compares renewTime + leaseDurationSeconds with the current time
- Avoids unnecessary leader updates if the lease is still active
- Updates renewTime if the current pod is already the leader
- Only changes the leader if the lease has expired

## What’s Improved?
- Avoids leader updates if lease is still valid
- Converts times to UNIX timestamps for easy comparison
- Uses jq to parse JSON output from kubectl get lease
- Ensures leader failover only when necessary

## Expected Result
- If the current leader is still active, no changes occur.
- If the leader pod dies or lease expires, another pod takes over.
- Failovers work efficiently with minimal downtime.

## Handling Simultaneous Leader Patches (Race Condition)
In a failover scenario, multiple pods (node-1 and node-2) may attempt to acquire leadership at the same time. This could lead to race conditions where both try to patch the Lease simultaneously.

## Solution
- Use a kubectl get lease immediately after patching to verify if the patch was successful.
- Introduce a random sleep time before retrying to reduce simultaneous patch attempts.
- Use kubectl patch --field-manager to ensure only one pod can claim leadership at a time.
  - This prevents conflicts from multiple simultaneous updates.

## Enhancements Added
- Race Condition Avoidance
  - After patching, we check again if the leader was updated successfully.
  - If another pod won the election, we don't retry immediately.
- Randomized Sleep to Avoid Collisions
  - Each pod waits 1-3 seconds before retrying leader election.
- Kubernetes --field-manager for Conflict Avoidance
  - This ensures only one pod successfully updates the Lease object at a time.

## Expected Outcome
- If two pods (node-1 & node-2) compete for leadership, only one will win.
- If a pod loses the race, it will detect the new leader and back off.
- Failover is smoother, avoiding unnecessary conflicts.
