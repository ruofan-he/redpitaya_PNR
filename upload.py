import sys
import json
from paramiko import SSHClient, AutoAddPolicy

def upload(host, port, user, passwd, uploadlist):
    ssh = SSHClient()
    ssh.set_missing_host_key_policy(AutoAddPolicy())

    ssh.connect(host, port, user, password=passwd)

    sftp = ssh.open_sftp()
    print("transferring to " + host + " ...", end='')
    for src, dst, filelist in uploadlist:
        for filename in filelist:
            sftp.put(src + filename, dst + filename)
    sftp.close()

    ssh.exec_command("sh start_scpi.sh")
    ssh.close()
    print(" end.")


filelist = json.load(open("upload_list.json"))
targetlist = json.load(open("target_list.json" if len(sys.argv) == 1 else sys.argv[1]))
for target in targetlist:
	upload(target["ip"], target["port"], target["user"], target["passwd"], filelist)
