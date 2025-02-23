import http.server
import socketserver
import os
import webbrowser
from threading import Timer

PORT = 8000
DIRECTORY = "build/web"

class Handler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=DIRECTORY, **kwargs)

def open_browser():
    webbrowser.open(f'http://localhost:{PORT}')

def run_server():
    with socketserver.TCPServer(("", PORT), Handler) as httpd:
        print(f"Server running at http://localhost:{PORT}")
        print("Press Ctrl+C to stop the server")
        try:
            Timer(2.0, open_browser).start()  # Open browser after 2 seconds
            httpd.serve_forever()
        except KeyboardInterrupt:
            print("\nServer stopped.")
            httpd.shutdown()

if __name__ == "__main__":
    if not os.path.exists(DIRECTORY):
        print(f"Building Flutter web app...")
        os.system("flutter build web")
    
    if os.path.exists(DIRECTORY):
        run_server()
    else:
        print("Error: Could not find the web build directory.")
