import socket


class SCPI_mannager():
    def __init__(self, host='localhost', port=5025):
        self.host = host
        self.port = port
    
    def ask(self, command):
        with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
            try:
                s.settimeout(5)
                s.connect((self.host, self.port))
                s.send(command)
                return s.recv(1024)
            except socket.timeout:
                print('timeout')
            except ConnectionError:
                print('connectionError')


    def idn(self):
        result = self.ask(b'*IDN?\n')
        print(result)


some = SCPI_mannager()
some.idn()