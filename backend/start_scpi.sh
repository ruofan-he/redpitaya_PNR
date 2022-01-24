make
cat red_pitaya_top.bit > /dev/xdevcfg
ps ax | pgrep -f scpi_server.py | awk '{print "kill -9", $1}' | sh
python3 scpi_server.py &
