import os
import base64
import json
from flask import Flask, request
from google.cloud import pubsub_v1
from google.cloud import secretmanager
from google.cloud import sql

app = Flask(__name__)

# Define environment variables
project_id = os.environ.get('PROJECT_ID')
cloudsql_instance_name = os.environ.get('CLOUDSQL_INSTANCE_NAME')
database_name = os.environ.get('DATABASE_NAME')
database_schema = os.environ.get('DATABASE_SCHEMA')
database_username = os.environ.get('DATABASE_USERNAME')

# Create a Cloud SQL connection
db = sql.connector.connect(
    user=database_username,
    password=secretmanager.SecretManagerServiceClient().access_secret_version(
        request={"name": "projects/{project_id}/secrets/[SECRET-NAME]/versions/latest"}
    ).payload.data.decode("UTF-8"),
    host=f"/cloudsql/{project_id}:{cloudsql_instance_name}",
    database=database_name
)

# Create a Pub/Sub publisher
publisher = pubsub_v1.PublisherClient()
topic_path = publisher.topic_path(project_id, 'lc-bq-update')

@app.route('/ingestion', methods=['PUT'])
def ingestion():
    data = request.get_json()

    # Write data to Cloud SQL
    cursor = db.cursor()
    query = f"INSERT INTO {database_schema} (ID, Name, LastName, FieldA, FieldB, FieldC) " \
            f"VALUES('{data['ID']}', '{data['Name']}', '{data['LastName']}', '{data['FieldA']}', " \
            f"'{data['FieldB']}', '{data['FieldC']}')"
    cursor.execute(query)
    db.commit()

    # Publish data to Pub/Sub
    message = json.dumps(data).encode('utf-8')
    future = publisher.publish(topic_path, data=message)
    future.result()

    return 'Data ingested and published to Pub/Sub'

@app.route('/query', methods=['GET'])
def query():
    what = request.args.get('what')
    where = request.args.get('where')

    # Query data from Cloud SQL
    cursor = db.cursor()
    query = f"SELECT * FROM {database_schema} WHERE {where} = '{what}'"
    cursor.execute(query)
    results = cursor.fetchall()

    response = []
    for row in results:
        response.append({
            'ID': row[0],
            'Name': row[1],
            'LastName': row[2],
            'FieldA': row[3],
            'FieldB': row[4],
            'FieldC': row[5]
        })

    return json.dumps(response)

if __name__ == '__main__':
    app.run()