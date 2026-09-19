import firebase_admin
from firebase_admin import credentials, firestore
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel


# ================= FIREBASE =================

cred = credentials.Certificate(
    "uyiraran-firebase-adminsdk-fbsvc-19f76b9849.json"
)

firebase_admin.initialize_app(cred)

db = firestore.client()


# ================= FASTAPI =================

app = FastAPI(title="Uyiraran Backend API")


# ================= CORS =================

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# ================= HOME =================

@app.get("/")
def home():
    return {
        "message": "Uyiraran Backend API is running"
    }


# ================= GET ALL WORKERS =================

@app.get("/api/workers")
def get_workers():

    workers_ref = db.collection("workers")

    workers = workers_ref.stream()

    worker_list = []

    for worker in workers:

        data = worker.to_dict()

        data["id"] = worker.id

        worker_list.append(data)

    return {
        "workers": worker_list
    }


# ================= GET ONE WORKER =================

@app.get("/api/workers/{worker_id}")
def get_worker(worker_id: str):

    workers_ref = db.collection("workers")

    query = (
        workers_ref
        .where("worker_id", "==", worker_id)
        .limit(1)
        .stream()
    )

    for worker in query:

        data = worker.to_dict()

        data["id"] = worker.id

        return data

    raise HTTPException(
        status_code=404,
        detail="Worker not found"
    )


# ================= SENSOR DATA MODEL =================

class SensorData(BaseModel):

    worker_id: str

    h2s: float

    location: str

    device: str

    risk: str = "low"

    exposer: float = 0


# ================= RECEIVE SENSOR DATA =================

@app.post("/api/sensor-data")
def receive_sensor_data(data: SensorData):

    workers_ref = db.collection("workers")

    query = (
        workers_ref
        .where(
            "worker_id",
            "==",
            data.worker_id
        )
        .limit(1)
        .stream()
    )

    worker_found = False

    for worker in query:

        worker_found = True

        worker.reference.update({

            "h2s": data.h2s,

            "location": data.location,

            "device": data.device,

            "risk": data.risk,

            "exposer": data.exposer

        })

        break

    if not worker_found:

        raise HTTPException(
            status_code=404,
            detail="Worker not found"
        )

    return {

        "message":
            "Sensor data updated successfully",

        "worker_id":
            data.worker_id,

        "h2s":
            data.h2s,

        "location":
            data.location,

        "device":
            data.device,

        "risk":
            data.risk,

        "exposer":
            data.exposer
    }