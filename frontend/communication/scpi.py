import socket
import pickle
import io


class SCPI_mannager():
    def __init__(self, host='localhost', port=5025):
        self.host = host
        self.port = port
    
    def ask(self, command, silent = False):
        # recv is blocking until any data added to socket buffer.
        # sometime, such as using real network instrument, overhead time allow to go over blocking before all data arrive.
        # While depending network instrument, <1kB data would arrive at once because not to divided into multiple packet.
        # Bigger data or some trouble time, please swich this ask func to ask_bigdata.
        # ask_bigdata will be almighty. But some overhead waiting time within.
        with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
            try:
                s.settimeout(2)
                s.connect((self.host, self.port))
                if type(command) == str:
                    command = command.encode()
                print(command)
                s.send(command)
                result = s.recv(8192)
                if not silent: print(result)
                return result
            except socket.timeout:
                print('timeout')
            except ConnectionError:
                print('connectionError')

    def ask_bigdata(self, command, silent = False):
        # ask_bigdata will repeat recv until timeout, meaning there is no data.
        with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
            try:
                s.settimeout(2)
                s.connect((self.host, self.port))
                if type(command) == str:
                    command = command.encode()
                print(command)
                s.send(command)

                s.settimeout(0.1)

                try:
                    result = b''
                    while True:
                        buff = s.recv(8192)
                        result += buff
                except socket.timeout:
                    if not silent: print(result)
                    return result if result else None
                
            except socket.timeout:
                print('timeout')
            except ConnectionError:
                print('connectionError')


    def idn(self):
        result = self.ask(b'*IDN?\n')
        return result

    def set_photon_threshold(self,num: int, value: int):
        self.ask(f'Set:Threshold:photon{num} {value}\n')

    def read_photon_threshold(self,num: int):
        result = self.ask(f'Read:Threshold:photon{num}\n')
        try:
            value = int(result)
        except:
            value = 0
        return value

    def set_trigger_level(self, value: int):
        self.ask(f'Set:Threshold:trig_threshold {value}\n')

    def read_trigger_level(self):
        result = self.ask('Read:Threshold:trig_threshold\n')
        try:
            value = int(result)
        except:
            value = 0
        return value
    
    def set_trigger_clearance(self, value: int):
        self.ask(f'Set:Timing:trig_clearance {value}\n')

    def read_trigger_clearance(self):
        result = self.ask(f'Read:Timing:trig_clearance\n')
        try:
            value = int(result)
        except:
            value = 0
        return value

    def set_trigger_delay(self, value: int):
        self.ask(f'Set:Timing:pnr_delay {value}\n')

    def read_trigger_delay(self):
        result = self.ask(f'Read:Timing:pnr_delay\n')
        try:
            value = int(result)
        except:
            value = 0
        return value

    def set_trig_positive_edge(self, value: bool):
        self.ask(f'Set:Flag:trig_is_posedge {int(value)}\n')
    
    def read_trig_positive_edge(self) -> bool:
        result = self.ask('Read:Flag:trig_is_posedge\n')
        try:
            value = bool(int(result))
        except:
            value = False
        return value

    def set_trig_is_a(self, value: bool):
        self.ask(f'Set:Flag:trig_is_adc_a {int(value)}\n')
    
    def read_trig_is_a(self) -> bool:
        result = self.ask('Read:Flag:trig_is_adc_a\n')
        try:
            value = bool(int(result))
        except:
            value = False
        return value
    
    def set_pnr_sig_inverse(self, value: bool):
        self.ask(f'Set:Flag:pnr_source_is_inverse {int(value)}\n')
    
    def read_pnr_sig_inverse(self) -> bool:
        result = self.ask('Read:Flag:pnr_source_is_inverse\n')
        try:
            value = bool(int(result))
        except:
            value = False
        return value

    def read_pnr_adc_fifo(self) -> list:
        result = self.ask_bigdata('Read:pnr_adc_fifo\n', silent=True)
        try:
            buff  = io.BytesIO(result)
            array = pickle.load(buff)
            assert type(array) == list
        except Exception as e:
            print(e)
            array = []
        return array
    
    def reset_adc_fifo(self):
        self.ask('Reset:adc_fifo\n')

    def set_dac_logic_mask(self, value: int):
        self.ask(f'Set:dac_logic_mask {value}\n')

    def read_dac_logic_mask(self) -> int:
        result = self.ask(f'Read:dac_logic_mask\n')
        try:
            value = int(result)
        except:
            value = 0
        return value




if __name__ == '__main__':
    some = SCPI_mannager()
    some.idn()
