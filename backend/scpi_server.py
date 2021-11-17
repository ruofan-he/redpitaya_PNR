#!/usr/bin/env python

"""
Run a multi-threaded single-client SCPI Server implemented in Python.
Using a single-client server is sensible for many SCPI servers
where state would need to be shared between the multiple clients
and thus access to it would need to be made thread-safe.
In most cases, this doesn't make sense. Everything is
simply much easier when allowing only one client at a time.
The design choice for a multi-threaded server was made in
order to be able to actively disconnect additional clients
while another one is already connected.
Contains code from https://gist.github.com/pklaus/db709c8c1279348e0638
"""

# Make it work on Python 2 and Python 3:
try:
    import socketserver
except ImportError:
    import SocketServer as socketserver
import socket, threading
import argparse, random, logging
from logging import DEBUG, INFO, WARNING, ERROR, CRITICAL

logger = logging.getLogger('scpi-server')

class CmdTCPServer(socketserver.ThreadingTCPServer):
    """
    A TCP server made to respond to line based commands.
    """

    #: newline character(s) to be added to string responses
    newline = '\n'
    #: Ctrl-C will cleanly kill all spawned threads
    daemon_threads = True
    #: much faster rebinding possible
    allow_reuse_address = True
    address_family = socket.AF_INET

    class CmdRequestHandler(socketserver.StreamRequestHandler):
        def handle(self):
            if not self.server.lock.acquire(blocking=False):
                self.log(DEBUG, 'An additional cliend tried to connect from {client}. Denying...')
                return
            self.log(DEBUG, 'Connected to {client}.')
            try:
                while True:
                    self.single_cmd()
            except Disconnected:
                pass
                self.log(DEBUG, 'The client {client} closed the connection')
            finally:
                self.server.lock.release()
        def read_cmd(self):
            return self.rfile.readline().decode('utf-8').strip()
        def log(self, level, msg, *args, **kwargs):
            if type(level) == str:
                level = getattr(logging, level.upper())
            msg = msg.format(client=self.client_address[0])
            logger.log(level, msg, *args, **kwargs)
        def send_reply(self, reply):
            if type(reply) == str:
                if self.server.newline: reply += self.server.newline
                reply = reply.encode('utf-8')
            self.wfile.write(reply)
        def single_cmd(self):
            cmd = self.read_cmd()
            if not cmd: raise Disconnected
            self.log(DEBUG, 'Received a cmd: {}'.format(cmd))
            try:
                reply = self.server.process(cmd)
                if reply is not None:
                    self.send_reply(reply)
            except:
                self.send_reply('ERR')

    def __init__(self, server_address, name=None):
        socketserver.TCPServer.__init__(self, server_address, self.CmdRequestHandler)
        self.lock = threading.Lock()
        self.name = name if name else "{}:{}".format(*server_address)

    def process(self, cmd):
        """
        Implement this method to handle command processing.
        For each command, this method will be called.
        Return a string or bytes as appropriate.
        If your the message is only a command (not a query), return None.
        """
        raise NotImplemented


import pickle
import io

# for connection test
class SCPIServerExample(CmdTCPServer):

    def process(self, cmd: str):
        """
        This is the method to process each SCPI command
        received from the client.
        """

        if cmd.startswith('*IDN?'):
            return self.name
        if cmd.startswith('READ?'):
            return '{:+.6E}'.format(random.random())

        else:
            return 'unknown cmd'

address_dict = {
    'led_o'                 :0x40600000,
    'trig_is_adc_a'         :0x40600004,
    'trig_threshold'        :0x40600008,
    'trig_hysteresis'       :0x4060000C,

    'trig_clearance'        :0x40600010,
    'trig_is_posedge'       :0x40600014,
    'pnr_delay'             :0x40600018,
    'pnr_source_is_inverse' :0x4060001C,

    'photon1'               :0x40600040,
    'photon2'               :0x40600044,
    'photon3'               :0x40600048,
    'photon4'               :0x4060004C,

    'photon5'               :0x40600050,
    'photon6'               :0x40600054,
    'photon7'               :0x40600058,
    'photon8'               :0x4060005C,

    'adc_fifo_data'         :0x40600070,
    'adc_fifo_counter'      :0x40600074,
    'adc_fifo_rst'          :0x40600078
}


# for redpitaya PNR scpi server 
class SCPIServerPNR(CmdTCPServer):

    def process(self, cmd: str):
        if cmd.startswith('*IDN?'):
            return self.name


        if cmd.startswith('Set:Threshold:'): # Set:Threshold:photon1 10000
            target = cmd[len('Set:Threshold:'):]
            try:
                success = set_threshold(target)
            except:
                success = False
            return 'yes' if success else 'no'

        if cmd.startswith('Read:Threshold:'): # Read:Threshold:photon1
            target = cmd[len('Read:Threshold:'):]
            try:
                result = read_threshold(target)
            except:
                result = None
            return '{}'.format(result) if result != None else 'no'


        if cmd.startswith('Set:Timing:'): # Set:Timing:trig_clearance 1000
            target = cmd[len('Set:Timing:'):]
            try:
                success = set_timing(target)
            except:
                success = False
            return 'yes' if success else 'no'

        if cmd.startswith('Read:Timing:'): # Read:Timing:trig_clearance
            target = cmd[len('Read:Timing:'):]
            try:
                result = read_timing(target)
            except:
                result = None
            return '{}'.format(result) if result != None else 'no'

        if cmd.startswith('Set:Flag:'): # Set:Flag:trig_is_posedge 1
            target = cmd[len('Set:Flag:'):]
            try:
                success = set_flag(target)
            except:
                success = False
            return 'yes' if success else 'no'

        if cmd.startswith('Read:Flag:'): # Read:Flag:trig_is_posedge
            target = cmd[len('Read:Flag:'):]
            try:
                result = read_flag(target)
            except:
                result = None
            return '{}'.format(result) if result != None else 'no'

        
        if cmd.startswith('Read:pnr_adc_fifo'): # Read:pnr_adc_fifo
            try:
                result = read_pnr_adc_fifo()
                buff = io.BytesIO()
                pickle.dump(result,buff)
                return buff.getvalue()
            except:
                return 'no'

        if cmd.startswith('Reset:adc_fifo'): # Reset:adc_fifo
            try:
                success = reset_adc_fifo()
            except:
                success = False
            return 'yes' if success else 'no'

        else:
            return 'unknown cmd'

def set_threshold(cmd: str):
    from monitor import write_value
    cmd_s = cmd.split()
    assert len(cmd_s) == 2
    assert cmd_s[0] in address_dict.keys()
    target = cmd_s[0]
    value = int(cmd_s[1]) # -8192 .. 8191
    assert -(1 << 13) <= value < (1<<13)
    bit_mask = (1 << 14) - 1
    signed_14bit_value = ((1<<14) + value) & bit_mask
    write_value(address_dict[target], signed_14bit_value)
    return True

def read_threshold(cmd: str):
    from monitor import read_value
    cmd_s = cmd.split()
    assert len(cmd_s) == 1
    assert cmd_s[0] in address_dict.keys()
    target = cmd_s[0]
    value = read_value(address_dict[target])
    value = value + (((value ^ (1 << 13)) & (1 << 13)) << 1) - (1 << 14)
    return value

def set_timing(cmd: str):
    from monitor import write_value
    cmd_s = cmd.split()
    assert len(cmd_s) == 2
    assert cmd_s[0] in address_dict.keys()
    target = cmd_s[0]
    value  = int(cmd_s[1]) # 0 .. 1<<32
    assert 0 <= value <= (1<<32)
    write_value(address_dict[target], value)
    return True

def read_timing(cmd: str):
    from monitor import read_value
    cmd_s = cmd.split()
    assert len(cmd_s) == 1
    assert cmd_s[0] in address_dict.keys()
    target = cmd_s[0]
    value = read_value(address_dict[target])
    return value

def set_flag(cmd: str):
    from monitor import write_value
    cmd_s = cmd.split()
    assert len(cmd_s) == 2
    assert cmd_s[0] in address_dict.keys()
    target = cmd_s[0]
    value  = 1 if int(cmd_s[1]) else 0 # 0 or 1
    assert value in [0,1]
    write_value(address_dict[target], value)
    return True

def read_flag(cmd: str):
    from monitor import read_value
    cmd_s = cmd.split()
    assert len(cmd_s) == 1
    assert cmd_s[0] in address_dict.keys()
    target = cmd_s[0]
    value = read_value(address_dict[target])
    return value

def read_pnr_adc_fifo():
    from monitor import read_value
    data_count = read_value(address_dict['adc_fifo_counter'])
    array = []
    for i in range(data_count):
        value = read_value(address_dict['adc_fifo_data'])
        array.append()
    return array
    
def reset_adc_fifo():
    from monitor import write_value
    write_value(address_dict['adc_fifo_rst'], 1)
    write_value(address_dict['adc_fifo_rst'], 0)
    return True


# ipv4 = os.popen('ip addr show eth0 | grep "\<inet\>" | awk \'{ print $2 }\' | awk -F "/" \'{ print $1 }\'').read().strip()

def main():
    parser = argparse.ArgumentParser(description=__doc__.split('\n')[1])
    parser.add_argument('--port', type=int, default=5025, help='TCP port to listen to.')
    parser.add_argument('--host', default='localhost', help='The host / IP address to listen at.')
    parser.add_argument('--loglevel', default='INFO', help='log level',
        choices=['CRITICAL', 'ERROR', 'WARNING', 'INFO', 'DEBUG'])
    parser.add_argument('-t','--test', action='store_true')
    args = parser.parse_args()
    logging.basicConfig(format='%(message)s', level=args.loglevel.upper())
    if args.test:
        scpi_server = SCPIServerExample((args.host, args.port))
    else:
        import os
        ipv4 = os.popen('ip addr show eth0 | grep "\<inet\>" | awk \'{ print $2 }\' | awk -F "/" \'{ print $1 }\'').read().strip()
        args.host = ipv4
        scpi_server = SCPIServerPNR((args.host, args.port))
    print(args.host)
    print(args.port)
    try:
        scpi_server.serve_forever()
    except KeyboardInterrupt:
        logger.info('Ctrl-C pressed. Shutting down...')
    scpi_server.server_close()

class Disconnected(Exception): pass

if __name__ == "__main__":
    main()