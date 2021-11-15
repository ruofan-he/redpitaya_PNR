import socket


class SCPI_mannager():
    def __init__(self, host='localhost', port=5025):
        self.host = host
        self.port = port
    
    def ask(self, command):
        with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
            try:
                s.settimeout(2)
                s.connect((self.host, self.port))
                if type(command) == str:
                    command = command.encode()
                s.send(command)
                return s.recv(1024)
            except socket.timeout:
                print('timeout')
            except ConnectionError:
                print('connectionError')


    def idn(self):
        result = self.ask(b'*IDN?\n')
        print(result)

    def set_photon_threshold(self,num: int, value: int):
        result = self.ask(f'Set:Threshold:photon{num} {value}\n')
        print(result)

    def read_photon_threshold(self,num: int):
        result = self.ask(f'Read:Threshold:photon{num}\n')
        try:
            value = int(result)
        except:
            value = 0
        return value

    def set_trigger_level(self, value: int):
        result = self.ask(f'Set:Threshold:trig_threshold {value}\n')
        print(result)

    def read_trigger_level(self):
        result = self.ask('Read:Threshold:trig_threshold\n')
        try:
            value = int(result)
        except:
            value = 0
        return value
    
    def set_trigger_clearance(self, value: int):
        result = self.ask(f'Set:Timing:trig_clearance {value}\n')
        print(result)

    def read_trigger_clearance(self):
        result = self.ask(f'Read:Timing:trig_clearance\n')
        try:
            value = int(result)
        except:
            value = 0
        return value

    def set_trigger_delay(self, value: int):
        result = self.ask(f'Set:Timing:pnr_delay {value}\n')
        print(result)

    def read_trigger_delay(self):
        result = self.ask(f'Read:Timing:pnr_delay\n')
        print(result)


if __name__ == '__main__':
    some = SCPI_mannager()
    some.idn()

