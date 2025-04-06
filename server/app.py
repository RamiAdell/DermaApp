from flask import Flask, request, jsonify
from flask_cors import CORS
import base64
import json

app = Flask(__name__)
CORS(app, resources={r"/*": {"origins": "*"}})  # Enable CORS for all routes and origins

@app.route('/predict', methods=['POST'])
def predict():
    try:
        print("Received request")
        data = request.get_json()

        if not data or 'image' not in data:
            return jsonify({'error': 'No image data received'}), 400

        # Get the image data and filename
        image_data = data['image']
        filename = data.get('filename', 'unknown.jpg')

        print(f"Processing image: {filename}")

        # For demo purposes, we'll return a constant response
        # In a real app, you would process the image here
        response = {
            'predicted_classes': ['Acne', 'Eczema', 'Disease'],
            'confidence': [0.85, 0.15, 0.05]
        }

        print("Sending response:", response)
        return jsonify(response)

    except Exception as e:
        print("Error:", str(e))
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    print("Server starting on all interfaces at port 5000")
    # Host '0.0.0.0' means accept connections from any IP
    app.run(host='0.0.0.0', port=5000, debug=True)