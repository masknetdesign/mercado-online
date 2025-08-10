#!/usr/bin/env python3
import http.server
import socketserver
import os
from urllib.parse import urlparse

class CustomHTTPRequestHandler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        # Parse the URL
        parsed_path = urlparse(self.path)
        path = parsed_path.path
        
        # Handle redirects based on netlify.toml configuration
        if path == '/admin':
            self.send_response(301)
            self.send_header('Location', '/admin/')
            self.end_headers()
            return
        elif path == '/client':
            self.send_response(301)
            self.send_header('Location', '/client/')
            self.end_headers()
            return
        elif path == '/':
            self.send_response(301)
            self.send_header('Location', '/client/')
            self.end_headers()
            return
        
        # Handle requests ending with trailing slash
        if path.endswith('/') and path != '/':
            # Check if this is a file path with trailing slash (like /admin/index.html/)
            if path.endswith('.html/'):
                # Remove trailing slash and serve the file
                file_path = path.rstrip('/')
                if os.path.exists(file_path.lstrip('/')):
                    self.path = file_path
                else:
                    self.send_error(404, f"File not found: {file_path}")
                    return
            else:
                # Handle directory requests
                directory_path = path.strip('/')
                index_file = os.path.join(directory_path, 'index.html')
                if os.path.exists(index_file):
                    # Serve the index.html file directly
                    self.path = '/' + index_file.replace('\\', '/')
                else:
                    # If directory doesn't exist, return 404
                    self.send_error(404, f"Directory not found: {path}")
                    return
        
        # Ignore common development files that don't exist
        if path in ['/@vite/client', '/sw.js']:
            self.send_error(404, "Development file not found")
            return
        
        # Handle 404 errors gracefully
        try:
            return super().do_GET()
        except FileNotFoundError:
            self.send_error(404, "File not found")
    
    def end_headers(self):
        # Add aggressive cache-busting headers
        self.send_header('Cache-Control', 'no-cache, no-store, must-revalidate, max-age=0')
        self.send_header('Pragma', 'no-cache')
        self.send_header('Expires', '0')
        self.send_header('Last-Modified', 'Thu, 01 Jan 1970 00:00:00 GMT')
        super().end_headers()
    
    def log_message(self, format, *args):
        # Custom logging to show cleaner messages
        print(f"[{self.address_string()}] {format % args}")

if __name__ == "__main__":
    PORT = 8000
    
    with socketserver.TCPServer(("", PORT), CustomHTTPRequestHandler) as httpd:
        print(f"Servidor rodando em http://localhost:{PORT}")
        print("Redirecionamentos configurados:")
        print("  /admin -> /admin/")
        print("  /client -> /client/")
        print("  / -> /client/")
        print("\nPressione Ctrl+C para parar o servidor")
        
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            print("\nServidor parado.")
            httpd.shutdown()