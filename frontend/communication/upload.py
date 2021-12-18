from paramiko import SSHClient, AutoAddPolicy

def upload(host, port, user, passwd, assets, exec_command):
    ssh = SSHClient()
    ssh.set_missing_host_key_policy(AutoAddPolicy())

    ssh.connect(host, port, user, password=passwd)

    sftp = ssh.open_sftp()
    print("transferring to " + host + " ...", end='')
    for src, dst, filelist in assets:
        for filename in filelist:
            sftp.put(src + filename, dst + filename)
    sftp.close()
    
    print(f"exec_command: {exec_command}")
    if exec_command: ssh.exec_command(exec_command)
    ssh.close()
    print(" end.")