import pytesseract
import PIL.Image
import io
import os
import json
from base64 import b64decode


LAMBDA_TASK_ROOT = os.environ.get('LAMBDA_TASK_ROOT', os.path.dirname(os.path.abspath(__file__)))
os.environ["PATH"] += os.pathsep + LAMBDA_TASK_ROOT


def call(event, context):
  print("Event Passed to Handler: " + json.dumps(event))
  image_base64 = json.loads(event['body'])['image64']
  binary = b64decode(image_base64)
  image = PIL.Image.open(io.BytesIO(binary))
  text = pytesseract.image_to_string(image, config='--psm 6')

  message = {
       'test': text
    }
  return {
      'statusCode': 200,
      'headers': {'Content-Type': 'application/json'},
      'body': json.dumps(message)
  }
