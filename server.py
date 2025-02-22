from flask import Flask, send_from_directory
import os
import logging

# إعداد السجلات
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# إنشاء تطبيق Flask
app = Flask(__name__)

# تحديد المجلد الحالي
current_dir = os.path.dirname(os.path.abspath(__file__))

@app.route('/')
def index():
    try:
        logger.info('Serving index.html')
        return send_from_directory(current_dir, 'index.html')
    except Exception as e:
        logger.error('Error serving index.html: %s', str(e))
        return str(e), 500

@app.route('/<path:path>')
def static_files(path):
    try:
        logger.info('Serving %s', path)
        return send_from_directory(current_dir, path)
    except Exception as e:
        logger.error('Error serving %s: %s', path, str(e))
        return str(e), 404

if __name__ == '__main__':
    try:
        logger.info('Starting server on port 5000')
        app.run(host='127.0.0.1', port=5000)
    except Exception as e:
        logger.error('Server failed to start: %s', str(e))
        raise
