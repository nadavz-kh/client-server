import py
import pytest
import subprocess
import socket
import os
import time
import asyncio

host = '127.0.0.1'
port = '6666'
repo_dir = os.path.dirname(os.path.dirname(__file__))
build_dir = os.path.join(repo_dir, 'Build/Products/Debug/')
server_exe_path = os.path.join(build_dir, 'Server')
client_exe_path = os.path.join(build_dir, 'Client')

def test_echo_server():
    data_to_send = b'lol1'
    server_cmd = [server_exe_path, port]
    server = subprocess.Popen(server_cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, bufsize=1, universal_newlines=True)
    import pdb;pdb.set_trace()
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        s.connect((host, int(port)))
        s.sendall(data_to_send)
        time.sleep(1)

    server.kill()
    output, err = server.communicate()
    assert data_to_send.decode('utf-8') in err
