from flask import Flask, request, jsonify
from kafka import KafkaProducer, KafkaConsumer
import threading
import json

app = Flask(__name__)

# Kafka Producer Setup
producer = KafkaProducer(
    bootstrap_servers='localhost:9092',
    value_serializer=lambda v: json.dumps(v).encode('utf-8')
)

# Kafka Consumer Setup
consumer = KafkaConsumer(
    'tank_updates',
    bootstrap_servers='localhost:9092',
    group_id='tank-group',
    auto_offset_reset='earliest',
    value_deserializer=lambda m: json.loads(m.decode('utf-8'))
)

latest_level = {"level": 0.0}

def consume_messages():
    global latest_level
    for message in consumer:
        latest_level = message.value

# Start Kafka Consumer in a separate thread
thread = threading.Thread(target=consume_messages, daemon=True)
thread.start()

@app.route('/kafka-proxy', methods=['POST'])
def kafka_proxy():
    topic = request.form.get('topic')
    message = request.form.get('message')
    producer.send(topic, {'level': float(message)})
    return jsonify({"status": "Message sent to Kafka", "message": message})

@app.route('/get-latest-level', methods=['GET'])
def get_latest_level():
    return jsonify(latest_level)

if __name__ == '__main__':
    app.run(debug=True)
