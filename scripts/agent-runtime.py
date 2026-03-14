import os
import sys
import json
import time
from datetime import datetime, timezone

# Gestión de estado y bloqueos para Agent Teams
CACHE_DIR = ".agent-cache"
LOCK_DIR = os.path.join(CACHE_DIR, "locks")

def init():
    os.makedirs(LOCK_DIR, exist_ok=True)

def acquire_lock(name, owner):
    lock_file = os.path.join(LOCK_DIR, f"{name}.lock")
    with open(lock_file, "w") as f:
        f.write(json.dumps({"owner": owner, "acquired_at": time.time()}))
    print(f"Lock {name} acquired by {owner}")

def release_lock(name):
    lock_file = os.path.join(LOCK_DIR, f"{name}.lock")
    if os.path.exists(lock_file):
        os.remove(lock_file)
        print(f"Lock {name} released")

if __name__ == "__main__":
    init()
    cmd = sys.argv[1]
    if cmd == "lock":
        action = sys.argv[2]
        if action == "acquire": acquire_lock(sys.argv[3], sys.argv[5])
        if action == "release": release_lock(sys.argv[3])