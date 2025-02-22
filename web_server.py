from http.server import HTTPServer, SimpleHTTPRequestHandler
import os
import webbrowser
import logging

# إعداد السجلات
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class WebServer:
    def __init__(self, port=8000):
        self.port = port
        self.web_dir = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'build/web')

    def start(self):
        try:
            # التأكد من وجود المجلد
            if not os.path.exists(self.web_dir):
                logger.error(f"مجلد {self.web_dir} غير موجود!")
                return

            # تغيير المجلد الحالي
            os.chdir(self.web_dir)
            
            # إنشاء الخادم
            server = HTTPServer(('0.0.0.0', self.port), SimpleHTTPRequestHandler)
            url = f'http://localhost:{self.port}'
            
            logger.info(f'بدء تشغيل الخادم على: {url}')
            
            # فتح المتصفح
            webbrowser.open(url)
            
            # تشغيل الخادم
            server.serve_forever()
            
        except Exception as e:
            logger.error(f'حدث خطأ: {str(e)}')

if __name__ == '__main__':
    server = WebServer()
    server.start()
