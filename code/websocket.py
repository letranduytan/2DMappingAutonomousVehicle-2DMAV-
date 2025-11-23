import websocket

def on_message(ws, message):
    print("Nhận:", message)

ws = websocket.WebSocketApp(
    "ws://192.168.4.1:81/",
    on_message=on_message
)

ws.run_forever()
