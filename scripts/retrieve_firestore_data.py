"""
retrieve_firestore_data.py
=========================
Script to retrieve and display all data from Firestore
"""

import firebase_admin
from firebase_admin import credentials, firestore
import json

# Initialize Firebase
SERVICE_ACCOUNT_PATH = "serviceAccountKey.json"

cred = credentials.Certificate(SERVICE_ACCOUNT_PATH)
firebase_admin.initialize_app(cred)
db = firestore.client()

print("✅ Firebase connected successfully.\n")

# Function to retrieve all documents from a collection
def retrieve_collection(collection_name):
    print(f"\n{'='*60}")
    print(f"📦 Collection: {collection_name}")
    print(f"{'='*60}")
    
    collection_ref = db.collection(collection_name)
    docs = collection_ref.stream()
    
    data = []
    for doc in docs:
        doc_data = doc.to_dict()
        doc_data['_id'] = doc.id
        data.append(doc_data)
    
    if data:
        print(f"Total documents: {len(data)}\n")
        print(json.dumps(data, indent=2, ensure_ascii=False, default=str))
    else:
        print("No documents found in this collection.")
    
    return data

# Retrieve all collections
all_data = {}

# Majors
all_data['majors'] = retrieve_collection('majors')

# Courses
all_data['courses'] = retrieve_collection('courses')

# Forum Posts
all_data['forum_posts'] = retrieve_collection('forum_posts')

# Users (if exists)
try:
    all_data['users'] = retrieve_collection('users')
except Exception as e:
    print(f"\n⚠️ Could not retrieve users collection: {e}")

# Save all data to a JSON file
output_file = 'firestore_data_export.json'
with open(output_file, 'w', encoding='utf-8') as f:
    json.dump(all_data, f, indent=2, ensure_ascii=False, default=str)

print(f"\n{'='*60}")
print(f"✅ All data has been exported to: {output_file}")
print(f"{'='*60}")
