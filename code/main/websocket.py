import websocket
import threading
import queue
import tkinter as tk
from matplotlib.backends.backend_tkagg import FigureCanvasTkAgg
import matplotlib.pyplot as plt
from matplotlib.animation import FuncAnimation
import math
import time

# =========================
# Queue dữ liệu IMU + Encoder
# =========================
data_queue = queue.Queue()

# =========================
# WebSocket callback
# =========================
def parse_imu(msg):
    data = {}
    for pair in msg.split():
        if '=' in pair:
            k, v = pair.split('=')
            data[k.strip()] = float(v)
    return data

def on_message(ws, message):
    data_queue.put(parse_imu(message))

def on_open(ws):
    print("WebSocket connected!")

def on_error(ws, error):
    print("WebSocket error:", error)

def on_close(ws, close_status_code, close_msg):
    print("WebSocket closed:", close_status_code, close_msg)

def run_ws():
    while True:
        ws = websocket.WebSocketApp(
            "ws://192.168.4.1:81/",
            on_open=on_open,
            on_message=on_message,
            on_error=on_error,
            on_close=on_close
        )
        ws.run_forever()
        time.sleep(1)  # reconnect

ws_thread = threading.Thread(target=run_ws)
ws_thread.daemon = True
ws_thread.start()

# =========================
# Tkinter GUI
# =========================
root = tk.Tk()
root.title("Robot IMU + Map")

frame_left = tk.Frame(root)
frame_right = tk.Frame(root)
frame_left.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)
frame_right.pack(side=tk.RIGHT, fill=tk.Y)

# =========================
# Bản đồ robot (Matplotlib)
# =========================
fig, ax = plt.subplots()
ax.set_xlabel("X (m)")
ax.set_ylabel("Y (m)")
ax.set_title("Quỹ đạo robot")
line, = ax.plot([], [], 'b-', lw=2)

canvas = FigureCanvasTkAgg(fig, master=frame_left)
canvas.get_tk_widget().pack(fill=tk.BOTH, expand=True)

# =========================
# Vị trí robot
# =========================
x, y = 0.0, 0.0
theta = 0.0  # hướng robot, rad
xs, ys = [x], [y]
distance = 0.0  # quãng đường tích lũy
dt = 0.1  # giả định khoảng thời gian giữa dữ liệu (s)

# =========================
# Bảng số liệu IMU + Encoder
# =========================
label_var = {}
for i, key in enumerate(["AX","AY","AZ","GX","GY","GZ","SPD1","SPD2","DIST"]):
    tk.Label(frame_right, text=key+":", font=("Arial", 14)).grid(row=i, column=0, sticky="w")
    var = tk.StringVar(value="0.000")
    tk.Label(frame_right, textvariable=var, font=("Arial", 14)).grid(row=i, column=1, sticky="w")
    label_var[key] = var

# =========================
# Hàm update GUI và bản đồ
# =========================
def update(frame):
    global x, y, theta, xs, ys, distance

    while not data_queue.empty():
        imu = data_queue.get()

        ax_val = imu.get("AX", 0)
        ay_val = imu.get("AY", 0)
        gz = imu.get("GZ", 0)
        spd1 = imu.get("SPD1", 0)
        spd2 = imu.get("SPD2", 0)

        # Cập nhật bảng số liệu
        for k in label_var:
            if k in imu:
                label_var[k].set(f"{imu[k]:.3f}")

        # Chuyển GZ sang rad
        gz_rad = math.radians(gz)

        # Cập nhật hướng
        theta += gz_rad * dt

        # Vận tốc trung bình 2 bánh
        v = (spd1 + spd2) / 2.0

        # Cập nhật vị trí dựa trên theta và tốc độ
        dx = v * math.cos(theta) * dt
        dy = v * math.sin(theta) * dt
        x += dx
        y += dy

        # Cập nhật quãng đường tích lũy
        distance += math.sqrt(dx**2 + dy**2)
        label_var["DIST"].set(f"{distance:.3f}")

        xs.append(x)
        ys.append(y)

    # Cập nhật đường đi
    line.set_data(xs, ys)
    ax.relim()
    ax.autoscale_view()
    canvas.draw()
    return line,

ani = FuncAnimation(fig, update, interval=100)
root.mainloop()
