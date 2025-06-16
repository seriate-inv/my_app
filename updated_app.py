from flask import Flask, request, jsonify
from flask_cors import CORS
from flask_mysqldb import MySQL
import datetime
import os
import re
from influxdb_client import InfluxDBClient

app = Flask(__name__)
CORS(app)

# --- MySQL Configuration ---
app.config['MYSQL_HOST'] = 'localhost'
app.config['MYSQL_USER'] = 'root'
app.config['MYSQL_PASSWORD'] = 'sheetal'
app.config['MYSQL_DB'] = 'my_app'
mysql = MySQL(app)

@app.route('/api/homogenizer', methods=['POST'])
def insert_temperature():
    try:
        data = request.get_json()
        temperature = data.get('temperature')
        speed = data.get('speed', 0)
        entry_index = data.get('entry_index', 0)

        cur = mysql.connection.cursor()
        cur.execute(
            "INSERT INTO homogenizer (entry_index, temperature, speed) VALUES (%s, %s, %s)",
            (entry_index, temperature, speed)
        )
        mysql.connection.commit()
        cur.close()

        return jsonify({'message': 'Data inserted successfully'}), 201
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/homogenizer', methods=['GET'])
def get_all_temperatures():
    cur = mysql.connection.cursor()
    cur.execute("SELECT entry_index, temperature, speed, timestamp FROM homogenizer ORDER BY timestamp DESC")
    rows = cur.fetchall()
    cur.close()

    result = []
    for row in rows:
        result.append({
            'entry_index': row[0],
            'temperature': row[1],
            'speed': row[2],
            'time': row[3].isoformat(),
        })
    return jsonify(result), 200

# --- 1. TC Heating Coil Endpoint ---
@app.route('/api/update_tc_temperatures', methods=['POST'])
def update_tc_temperatures():
    try:
        data = request.get_json()
        temperatures = data.get('temperatures', [])

        cursor = mysql.connection.cursor()
        
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS TC_Heating_coil (
                id INT AUTO_INCREMENT PRIMARY KEY,
                entry_index INT NOT NULL,
                temperature DECIMAL(10,2) NOT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        """)
        
        for entry in temperatures:
            index = entry.get('index')
            temperature = entry.get('temperature')
            
            if index is None or temperature is None:
                continue
            
            cursor.execute(
                "INSERT INTO TC_Heating_coil (entry_index, temperature) VALUES (%s, %s)",
                (index, temperature)
            )

        mysql.connection.commit()
        cursor.close()
        return jsonify({'message': 'Temperature data inserted successfully'}), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

# --- 2. TI5 Heat Exchanger ---
@app.route('/api/ti5_heat_exchanger', methods=['POST'])
def insert_ti5_manual_values():
    try:
        data = request.get_json()
        entry_index = data.get('entry_index')
        temperature = data.get('temperature')
        timestamp = datetime.datetime.utcnow().strftime('%Y-%m-%d %H:%M:%S')

        if entry_index is None or temperature is None:
            return jsonify({'error': 'Missing entry_index or temperature'}), 400

        cursor = mysql.connection.cursor()
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS TI5_heat_exchanger (
                id INT AUTO_INCREMENT PRIMARY KEY,
                entry_index INT NOT NULL,
                temperature DECIMAL(10,2) NOT NULL,
                timestamp DATETIME NOT NULL
            )
        ''')
        cursor.execute(
            "INSERT INTO TI5_heat_exchanger (entry_index, temperature, timestamp) VALUES (%s, %s, %s)",
            (entry_index, temperature, timestamp)
        )
        mysql.connection.commit()
        cursor.close()
        return jsonify({'message': 'TI5 value inserted successfully'}), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

# --- 3. Save Generic Temperature ---
@app.route('/api/save_temperature', methods=['POST'])
def save_temperature():
    try:
        data = request.get_json()
        table_name = data.get('table_name')
        value = data.get('value')
        index = data.get('index')
        timestamp = data.get('timestamp', datetime.datetime.utcnow().strftime('%Y-%m-%d %H:%M:%S'))

        if not table_name or not re.match(r'^[a-zA-Z0-9_]+$', table_name):
            return jsonify({'error': 'Invalid table name'}), 400

        cursor = mysql.connection.cursor()
        cursor.execute(f'''
            CREATE TABLE IF NOT EXISTS `{table_name}` (
                id INT AUTO_INCREMENT PRIMARY KEY,
                value DOUBLE NOT NULL,
                index_position INT NOT NULL,
                timestamp DATETIME NOT NULL
            )
        ''')
        cursor.execute(f'''
            INSERT INTO `{table_name}` (value, index_position, timestamp)
            VALUES (%s, %s, %s)
        ''', (value, index, timestamp))
        mysql.connection.commit()
        cursor.close()
        return jsonify({'message': f'Data saved to {table_name}'}), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/get_updated_values', methods=['POST'])
def get_updated_values():
    try:
        data = request.get_json()
        table_name = data.get('table_name')

        if not table_name or not re.match(r'^[a-zA-Z0-9_]+$', table_name):
            return jsonify({'error': 'Invalid table name'}), 400

        cursor = mysql.connection.cursor()
        cursor.execute(f'''
            SELECT index_position, value 
            FROM `{table_name}`
            ORDER BY timestamp DESC
        ''')
        
        result = {}
        for row in cursor.fetchall():
            index_pos = row[0]
            if index_pos not in result:
                result[index_pos] = row[1]
        
        cursor.close()
        return jsonify([{'index_position': k, 'value': v} for k, v in result.items()]), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@app.route('/api/ti5_heat_exchanger', methods=['POST'])
def save_ti5_temperature():
    data = request.get_json()
    entry_index = data.get('entry_index')
    temperature = data.get('temperature')
    timestamp = datetime.datetime.now()

    if entry_index is None or temperature is None:
        return jsonify({'error': 'Missing data'}), 400

    cursor = mysql.connection.cursor()
    cursor.execute("""
        INSERT INTO TI5_heat_exchanger (entry_index, temperature, timestamp)
        VALUES (%s, %s, %s)
    """, (entry_index, temperature, timestamp))
    mysql.connection.commit()
    cursor.close()

    return jsonify({'message': 'Value saved successfully'}), 200


# --- Homogenizer Endpoint ---


# --- TI5 Values Endpoint ---
@app.route('/api/get_ti5_values', methods=['GET'])
def get_ti5_values():
    try:
        cursor = mysql.connection.cursor()
        cursor.execute('''
            SELECT entry_index, temperature 
            FROM TI5_heat_exchanger
            ORDER BY timestamp DESC
        ''')
        
        result = {}
        for row in cursor.fetchall():
            index = row[0]
            if index not in result:
                result[index] = row[1]
        
        cursor.close()
        return jsonify([{'entry_index': k, 'temperature': float(v)} for k, v in result.items()]), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/fetch_updated_temperatures', methods=['GET'])
def fetch_updated_temperatures():
    cur = mysql.connection.cursor()
    cur.execute("SELECT entry_index, temperature FROM TC_Heating_coil ORDER BY entry_index ASC")
    rows = cur.fetchall()
    cur.close()

    result = [
        {'index': row[0], 'temperature': float(row[1])}
        for row in rows
    ]
    return jsonify(result)

# --- InfluxDB Configuration ---
INFLUX_URL = "http://localhost:8086"
INFLUX_TOKEN = os.getenv('INFLUX_TOKEN', "8cGJFIf0B6P3ArVt_L5oVCyN7bDCwyAT_JpjZRHtvb_0gxWn0Y9ONfuyzP5HZT42noABogeypy7-ijPMbcfn0g==")
INFLUX_ORG = "seriate"
INFLUX_BUCKET = "1"

def query_influx_temperature_speed():
    query = '''
    from(bucket: "1")
      |> range(start: -3mo)
      |> filter(fn: (r) => r["_field"] == "speed" or r["_field"] == "temp")
      |> aggregateWindow(every: 1m, fn: mean, createEmpty: false)
      |> pivot(rowKey:["_time"], columnKey: ["_field"], valueColumn: "_value")
      |> yield(name: "mean")
    '''
    client = None
    try:
        client = InfluxDBClient(url=INFLUX_URL, token=INFLUX_TOKEN, org=INFLUX_ORG, timeout=30000)
        tables = client.query_api().query(query)
        results = []

        for table in tables:
            for record in table.records:
                results.append({
                    "time": record.get_time().isoformat(),
                    "speed": record.values.get("speed", 0),
                    "temperature": record.values.get("temp", 0)
                })
        return results
    except Exception as e:
        return {"error": str(e)}
    finally:
        if client:
            client.close()

@app.route('/api/tank', methods=['GET'])
@app.route('/api/temperature', methods=['GET'])
def get_influx_data():
    data = query_influx_temperature_speed()
    if isinstance(data, dict) and "error" in data:
        return jsonify(data), 500
    return jsonify(data)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
