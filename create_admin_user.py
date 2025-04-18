# create_admin_user.py

import os
import sqlite3

# Path to your OpenPLC database inside the container
db_path = '/workdir/webserver/openplc.db'

# Check if the database exists
if not os.path.exists(db_path):
    print("❌ Database not found at", db_path)
    exit(1)

# Connect to the database
conn = sqlite3.connect(db_path)
cursor = conn.cursor()

# Check if 'Users' table exists
try:
    cursor.execute("SELECT name FROM sqlite_master WHERE type='table' AND name='Users'")
    if not cursor.fetchone():
        print("❌ Users table not found in database.")
        conn.close()
        exit(1)
except Exception as e:
    print(f"❌ Error checking tables: {e}")
    conn.close()
    exit(1)

# Check if admin user already exists
cursor.execute("SELECT * FROM Users WHERE username = 'admin'")
admin_exists = cursor.fetchone()

if not admin_exists:
    print("✅ Admin user not found, creating default admin/admin account...")
    cursor.execute("INSERT INTO Users (username, password, email, userType) VALUES ('admin', 'admin', 'admin@ess.local', 'admin')")
    conn.commit()
    print("✅ Admin user created successfully!")
else:
    print("⚡ Admin user already exists. No action needed.")

conn.close()
