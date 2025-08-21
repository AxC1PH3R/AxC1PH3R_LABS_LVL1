#!/usr/bin/env python3
import socket, threading

BANNER = b"220 AxCipher CTF Service ready \xF0\x9F\x9A\xA9 flag{nmap_banner_flag}\r\n"

def handle(conn):
    try:
        conn.sendall(BANNER)  # initial banner (CRLF)
        conn.settimeout(5)
        while True:
            data = conn.recv(512)
            if not data:
                break
            line = data.strip().upper()
            if line.startswith(b"EHLO") or line.startswith(b"HELO"):
                conn.sendall(b"250-ok\r\n")
            elif line.startswith(b"QUIT"):
                conn.sendall(b"221 bye\r\n")
                break
            else:
                conn.sendall(b"502 command not implemented\r\n")
    except Exception:
        pass
    finally:
        try: conn.close()
        except: pass

def main():
    s = socket.socket()
    s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    s.bind(("0.0.0.0", 1337))
    s.listen(5)
    print("[ctf1337] Listening on :1337")
    while True:
        conn, _ = s.accept()
        threading.Thread(target=handle, args=(conn,), daemon=True).start()

if __name__ == "__main__":
    main()
