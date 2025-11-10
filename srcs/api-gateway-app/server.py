import os
from flask import jsonify
from app import create_app

app = create_app()

# --- Добавляем приветственный маршрут ---
@app.route("/")
def home():
    return jsonify({
        "message": "Welcome to Play with Containers API Gateway 🚀",
        "status": "running",
        "endpoints": ["/health", "/inventory", "/billing"]
    })

if __name__ == '__main__':
    port = int(os.getenv('APP_PORT', 3000))
    app.run(host='0.0.0.0', port=port, debug=False)
