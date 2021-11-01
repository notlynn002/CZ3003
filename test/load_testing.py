import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore

import time
import concurrent.futures


def connection():
    cred = credentials.Certificate(
        'ServiceAccountKey.json')

    if not len(firebase_admin._apps):
        firebase_admin.initialize_app(cred, {
            'projectid': 'godotmathgame-c219e'
        })
    else:
        firebase_admin.get_app()

    return firestore.client()


## Load testing code
def insertion(db, no_of_times):
    doc_ref = db.collection(u'User').document(u'testing')
    doc_ref.set({
        f'test{no_of_times}': u'test value'
    }, merge=True)
    return "Done inserting to db"


t1 = time.perf_counter()

with concurrent.futures.ThreadPoolExecutor() as executor:
    db = connection()
    test = range(0, 1000)
    results = [executor.submit(insertion(db, i)) for i in test]

t2 = time.perf_counter()

print(f"done in {t2-t1}(s)")

