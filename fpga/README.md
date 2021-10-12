# redpitaya_fpga
## command
### create vivado project
```
vivado -mode batch -source red_pitaya_vivado_project_Z10.tcl
```

### build fpga project
```
vivado -mode batch -source red_pitaya_vivado_Z10.tcl
```

## environment
下記推奨
```
vivado 2020.1
(ip/systemZ10.tc. systemブロックデザイン生成スクリプトがvivado2020.1で作られたため)
```
新しいvivadoに対応させるためには、作ったプロジェクトを新しいバージョンのvivadoに読み込ませて、
そのバージョンでブロックデザインのtclを出力して置き換える。もちろんそうすると2020.1では使えなくなる。


## ブロックデザイン追加
ブロックデザインをtcl出力し(例`users_bd.tcl`など)、適当なところにおく。それと同時にuser_bd.tclに該当tclの実行文を追加する。
```
source users_bd.tcl
generate_target all [get_files    users_bd.bd]
```