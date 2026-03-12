from flask import Flask, jsonify, request
import time
import math
import random

app = Flask(__name__)

# Interner Zustand (für v_max, v_average, distance, height_cm usw.)
state = {
    "v_max": 0.0,
    "v_average": 0.0,
    "distance": 0.0,
    "height_cm": 0.0,
}

start_ts = time.time()

def synth_values(t: float) -> dict:
    drive = max(0.0, math.sin(t / 6.0))
    v_real = 80.0 * drive + random.uniform(-1.0, 1.0)
    v_real = max(0.0, v_real)

    v_mod = v_real * 0.6

    state["distance"] += (v_real * 1000.0 / 3600.0) * 1.0
    state["height_cm"] = 50.0 + 20.0 * math.sin(t / 10.0)

    slope_pct = 5.0 * math.sin(t / 8.0)
    inclination_deg = math.degrees(math.atan(slope_pct / 100.0))

    temperature_C = 22.0 + 2.0 * math.sin(t / 30.0)
    pressure_hPa = 1013.0 + 5.0 * math.sin(t / 50.0)
    humidity_pct = 45.0 + 10.0 * math.sin(t / 40.0)

    battery = max(0.0, min(100.0, 100.0 - (t / 1200.0) * 30.0))

    state["v_max"] = max(state["v_max"], v_real)
    alpha = 0.05
    state["v_average"] = (1 - alpha) * state["v_average"] + alpha * v_real

    track_voltage = 16.0 + 2.0 * drive + random.uniform(-0.2, 0.2)
    track_voltage = max(0.0, track_voltage)

    return {
        "v_mod": v_mod,
        "v_real": v_real,
        "v_max": state["v_max"],
        "v_average": state["v_average"],
        "distance": state["distance"],
        "slope_pct": slope_pct,
        "inclination_deg": inclination_deg,
        "temperature_C": temperature_C,
        "pressure_hPa": pressure_hPa,
        "humidity_pct": humidity_pct,
        "batteryPercent": battery,
        "voltage": track_voltage
    }

@app.get("/api/data")
def api_data():
    t = time.time() - start_ts
    return jsonify(synth_values(t))

@app.post("/api/command")
def api_command():
    payload = request.get_json(silent=True) or {}

    # Erwartet z.B. {"reset_v_max": true}
    if payload.get("reset_v_max"):
        state["v_max"] = 0.0
    if payload.get("reset_v_average"):
        state["v_average"] = 0.0
    if payload.get("reset_distance"):
        state["distance"] = 0.0
    if payload.get("reset_height"):
        state["height_cm"] = 0.0

    return jsonify({"ok": True, "applied": payload})

if __name__ == "__main__":
    # 0.0.0.0: auch von anderen Geräten im LAN erreichbar
    app.run(host="0.0.0.0", port=4000, debug=False)