#!/usr/local/bin/python

from http.server import BaseHTTPRequestHandler, HTTPServer
import subprocess
import logging

PORT = 8081


class RequestHandler(BaseHTTPRequestHandler):
    def _set_response(self):
        self.send_response(200)
        self.send_header('Content-type', 'text/html')
        self.end_headers()

    def do_POST(self):
        content_length = int(self.headers['Content-Length']) # <--- Gets the size of data
        post_data = self.rfile.read(content_length) # <--- Gets the data itself
        logging.info("POST request,\nPath: %s\nHeaders:\n%s\n\nBody:\n%s\n",
                str(self.path), str(self.headers), post_data.decode('utf-8'))

        self._set_response()
        subprocess.run(
                "git clone https://gitlab.com/gitlab-data/analytics.git",
                shell=True,
                check=True
        )
        logging.info("Repo successfully cloned.")


def run_server(server_class, handler_class, port):
    """
    Run a webserver that pulls a git repo on POST.
    """

    server_address = ('', port)
    httpd = server_class(server_address, handler_class)
    logging.info(f"Starting server on port: {port}...\n")
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        pass
    httpd.server_close()
    logging.info("Stopping server...\n")

if __name__ == '__main__':
    logging.basicConfig(level=logging.INFO)
    run_server(HTTPServer, RequestHandler, PORT)
