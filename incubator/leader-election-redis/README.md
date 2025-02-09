# Leader Election using Redis
---

## How it Works
- Tries to acquire leadership using SET leader podName NX EX 5.
- If another pod is the leader, it keeps checking (GET leader).
- If already the leader, it renews the lease (SET leader podName XX EX 5).
- Failover happens automatically when the leader pod stops renewing.

## Now, Leadership is Managed via Redis Mutex!
- The Redis lease prevents race conditions.
- No need for leader.txt anymore.
- Pods can take over seamlessly when the leader fails.

## Is This Redis Lock Write-Safe?
Currently, the implementation uses SET NX EX to acquire the lock and SET XX EX to renew it. However, there is a small race condition:
- If the leader pod crashes before renewing the lease, the lock expires.
- Multiple other pods might race to acquire the lock at the same time.
- Two pods might momentarily believe they are the leader due to concurrent Redis writes.

## How Can Another Pod Capture the Lock Before Lease Ends?
Yes, in the current implementation, another pod cannot take over before the lease expires, because:

- SET NX (Only Set if Not Exists) ensures that only the first pod gets the lock.
- The EX (expiry) ensures that Redis automatically releases the lock if the leader pod crashes.

However, there is a small vulnerability:

- If the leader is slow in renewing (e.g., due to network delays or CPU contention), the lease might expire before renewal.
- Another pod could acquire the lock before the original leader realizes it's lost.

## How to Make This Fully Write-Safe?
We need a safer locking mechanism that ensures atomic writes and prevents race conditions.

Solution: Use SET NX EX + Compare-and-Swap (GET + SET)

- Use SET NX EX for first-time leadership acquisition.
- Before renewing, ensure the pod still owns the lock.
- Use a transaction (Lua script) to renew only if the pod is still the leader.

## Key Improvements
- Prevents race conditions: Uses a Lua script (EVAL) to renew only if the pod is still the leader.
- Write-safe leader renewal: Ensures that the pod renewing leadership is still the active leader.
- Avoids accidental double leaders: If another pod has taken over, the current pod detects the change immediately.

## How This Solves the Race Condition
- Only one pod can set the lock initially (SET NX EX).
- Renewing the lease (SET XX EX) is now atomic:
  - It only happens if the current pod is still the leader.
  - Uses a Lua transaction to prevent overwrites.
- If the leader fails before renewing, another pod waits for expiration and then wins leadership.

## Now, Leadership is Strongly Consistent!
- No accidental double leaders.
- Leader renewals are atomic.
- Failover is race-free.

## Here’s the updated C++ code that:
- Ensures only the leader can write to /shared/leaders.log
- Stops writing if the leadership changes
- Reads Redis configurations from environment variables
- Uses Redis for leader election with a safe locking mechanism

## Enhancements
- Log File Write Restriction:
  - Only the current leader writes to /shared/leaders.log.
  - If leadership changes, log writing stops immediately.
- Race-Free Leadership Election:
  - Uses SET NX EX for initial leadership acquisition.
  - Uses Lua scripting (EVAL) for safe renewal.
  - If lease is expired, another pod takes over cleanly.
- Reads Configurations from Environment Variables:
  - REDIS_HOST (default: 127.0.0.1)
  - REDIS_PORT (default: 6379)
  - LEADER_KEY (default: "leader")
  - LEASE_TIME (default: 5 seconds)
- Automatically Stops Writing Logs When Losing Leadership.

## How This Works
- Leader Pod (e.g., my-app-0) writes to Redis (SET NX EX).
- Leader periodically renews lease (SET EX with Lua transaction).
- Writes logs to /shared/leaders.log.
- If another pod becomes leader, it stops writing immediately.
- If the leader crashes, another pod (my-app-1 or my-app-2) takes over.
Now, the system prevents split-brain scenarios and ensures only one leader writes logs at a time.

## Expected Behavior
- Only one pod (leader) should write to /shared/leaders.log.
- Other pods should stay in hot standby and keep checking for leadership.
- If the leader crashes, one of the standby pods should become the new leader without exiting/restarting.

## Fix the C++ Code
Your C++ application should not exit when it loses leadership. Instead, it should:
- Continuously check leadership using Redis.
- If it loses leadership, simply stop writing logs.
- If it becomes leader again, resume writing logs.

## Why This Fix Works?
- The app does not exit when it loses leadership.
- It continuously monitors Redis to detect leader changes.
- Leadership is re-acquired if the current leader crashes.
- Log writing stops automatically if another pod becomes leader.

Now, Kubernetes will not restart the pod unnecessarily, ensuring a smooth failover.

## Enhancements Needed
- Renew Leadership Instead of Losing It Instantly:
  - If the pod is already the leader, it should try to renew the lease before it expires.
  - Avoid letting other pods race to become the leader immediately.
- Prevent Redis Race Condition on Leadership Change:
  - Introduce an Atomic Renewal Check where the pod tries to extend its lease before giving up leadership.
  - If the lease is still valid, it should not allow others to take over unless it truly crashes.

## Why is Leadership Flipping?
- Lease Expiration Before Renewal
  - Each pod acquires leadership, but the renewal mechanism isn't working reliably.
  - Once the lease expires, another pod immediately takes over.
- Lack of Atomic Renewal Strategy
  - Redis SET NX PX only sets a key if it does not exist (NX → "only if not exists").
  - However, when renewing, we need SET XX PX (XX → "only if exists").
  - If the pod does not renew in time, others take over immediately.

## Fixed Leadership Election Strategy
- Try renewing the lease before it expires.
- Only attempt to acquire leadership if no other leader exists.
- Introduce a small buffer (e.g., renew lease 80% into expiration).

## Fixes & Enhancements
- Leadership Stability
  - Leader renews its lease at 80% of expiration time.
  - Prevents unnecessary leader changes.
- Prevents Leader Race Conditions
  - If leadership is already held, it tries to renew instead of reacquiring.
  - If renewal fails, another pod takes over.
- Avoids Sudden Leader Drops
  - If leadership is still valid, it does not allow a new pod to take over immediately.
