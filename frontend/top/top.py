import sys
import os
from PyQt5 import QtWidgets, uic, QtCore
import pyqtgraph as pg
import numpy as np
from ..communication import SCPI_mannager


class graph_view(pg.GraphicsLayoutWidget):
    def __init__(self, top_window):
        super().__init__(show=True)
        self.top_window : Top_window = top_window # parent
        self.plt1 = self.addPlot()


        self.vals = []
        y,x = np.histogram([])
        self.hist : pg.PlotDataItem= self.plt1.plot(x, y, stepMode="center", fillLevel=0, fillOutline=True, brush=(0,0,255,150))
        self.update_hist()

        
        self.line_photon1 = pg.InfiniteLine(movable=True, angle=90, label='1:{value:0.0f}', 
                       labelOpts={'position':0.1, 'color': (200,200,100), 'fill': (200,200,200,50), 'movable': False})
        self.line_photon2 = pg.InfiniteLine(movable=True, angle=90, label='2:{value:0.0f}', 
                       labelOpts={'position':0.2, 'color': (200,200,100), 'fill': (200,200,200,50), 'movable': False})
        self.line_photon3 = pg.InfiniteLine(movable=True, angle=90, label='3:{value:0.0f}', 
                       labelOpts={'position':0.3, 'color': (200,200,100), 'fill': (200,200,200,50), 'movable': False})
        self.line_photon4 = pg.InfiniteLine(movable=True, angle=90, label='4:{value:0.0f}', 
                       labelOpts={'position':0.4, 'color': (200,200,100), 'fill': (200,200,200,50), 'movable': False})
        self.line_photon5 = pg.InfiniteLine(movable=True, angle=90, label='5:{value:0.0f}', 
                       labelOpts={'position':0.5, 'color': (200,200,100), 'fill': (200,200,200,50), 'movable': False})
        self.line_photon6 = pg.InfiniteLine(movable=True, angle=90, label='6:{value:0.0f}', 
                       labelOpts={'position':0.6, 'color': (200,200,100), 'fill': (200,200,200,50), 'movable': False})
        self.line_photon7 = pg.InfiniteLine(movable=True, angle=90, label='7:{value:0.0f}', 
                       labelOpts={'position':0.7, 'color': (200,200,100), 'fill': (200,200,200,50), 'movable': False})
        self.line_photon8 = pg.InfiniteLine(movable=True, angle=90, label='8:{value:0.0f}', 
                       labelOpts={'position':0.8, 'color': (200,200,100), 'fill': (200,200,200,50), 'movable': False})


        self.plt1.addItem(self.line_photon1)
        self.plt1.addItem(self.line_photon2)
        self.plt1.addItem(self.line_photon3)
        self.plt1.addItem(self.line_photon4)
        self.plt1.addItem(self.line_photon5)
        self.plt1.addItem(self.line_photon6)
        self.plt1.addItem(self.line_photon7)
        self.plt1.addItem(self.line_photon8)


        def temp_func():
            self.on_line_dragged()
            self.top_window.display_value()

        self.line_photon1.sigPositionChangeFinished.connect(temp_func)
        self.line_photon2.sigPositionChangeFinished.connect(temp_func)
        self.line_photon3.sigPositionChangeFinished.connect(temp_func)
        self.line_photon4.sigPositionChangeFinished.connect(temp_func)
        self.line_photon5.sigPositionChangeFinished.connect(temp_func)
        self.line_photon6.sigPositionChangeFinished.connect(temp_func)
        self.line_photon7.sigPositionChangeFinished.connect(temp_func)
        self.line_photon8.sigPositionChangeFinished.connect(temp_func)

        

    def photon_threshold_set(self, value_dict: dict):
        assert len(value_dict) == 8
        self.line_photon1.setValue(value_dict['photon1'])
        self.line_photon2.setValue(value_dict['photon2'])
        self.line_photon3.setValue(value_dict['photon3'])
        self.line_photon4.setValue(value_dict['photon4'])
        self.line_photon5.setValue(value_dict['photon5'])
        self.line_photon6.setValue(value_dict['photon6'])
        self.line_photon7.setValue(value_dict['photon7'])
        self.line_photon8.setValue(value_dict['photon8'])

    def update_hist(self):
        bins = 1 if len(self.vals) == 0 else np.linspace(min(self.vals) - 0.5, max(self.vals) + 0.5 , max(self.vals) - min(self.vals) + 2)
        y,x = np.histogram(self.vals, bins= bins )
        self.hist.setData(x,y)

    def append_data(self, array: list):
        self.vals = self.vals + array
        self.update_hist()

    def on_line_dragged(self):
        value_dict = {
            'photon1':round(self.line_photon1.value()),
            'photon2':round(self.line_photon2.value()),
            'photon3':round(self.line_photon3.value()),
            'photon4':round(self.line_photon4.value()),
            'photon5':round(self.line_photon5.value()),
            'photon6':round(self.line_photon6.value()),
            'photon7':round(self.line_photon7.value()),
            'photon8':round(self.line_photon8.value())
        }
        
        self.top_window.photon_threshold_set(value_dict)

    def reset_graph(self):
        self.vals = []
        self.update_hist()

    



class Top_window(QtWidgets.QMainWindow):
    def __init__(self, parent=None):
        super().__init__(parent)
        dir_name = os.path.dirname(__file__)
        uic.loadUi(os.path.join(dir_name, 'top.ui'), self)
        self.setWindowTitle('Redpitaya photon number resolver controller')
        self.setFixedSize(self.size())
        self.attach_graph()
        self.toggle_config_input(False)
        self.scpi_mannager: SCPI_mannager = None

        self.pushButton_connect.clicked.connect(self.push_connect)
        self.pushButton_disconnect.clicked.connect(self.push_disconnect)

        self.lineEdit_port.setText('5025')

        def trigger_level_slider_change(value):
            self.spinBox_trigger_level.setValue(value)
            self.display_value()
        def trigger_level_spin_change(value):
            self.horizontalSlider_trigger_level.setValue(value)
            self.display_value()


        self.horizontalSlider_trigger_level.valueChanged.connect(trigger_level_slider_change)
        self.spinBox_trigger_level.valueChanged.connect(trigger_level_spin_change)

        self.spinBox_trigger_delay.valueChanged.connect(self.display_value)
        self.spinBox_trigger_clearance.valueChanged.connect(self.display_value)
        self.spinBox_photon1.valueChanged.connect(self.display_value)
        self.spinBox_photon2.valueChanged.connect(self.display_value)
        self.spinBox_photon3.valueChanged.connect(self.display_value)
        self.spinBox_photon4.valueChanged.connect(self.display_value)
        self.spinBox_photon5.valueChanged.connect(self.display_value)
        self.spinBox_photon6.valueChanged.connect(self.display_value)
        self.spinBox_photon7.valueChanged.connect(self.display_value)
        self.spinBox_photon8.valueChanged.connect(self.display_value)

        self.pushButton_read.clicked.connect(self.push_read)
        self.pushButton_write.clicked.connect(self.push_write)
        self.pushButton_graph_reset.clicked.connect(self.push_graph_reset)

        self.pushButton_graph_load.clicked.connect(self.push_graph_load)


        



    def ui_components(self):
        # just type hint
        self.graph_container                    : QtWidgets.QGridLayout = None
        self.pushButton_connect                 : QtWidgets.QPushButton = None
        self.pushButton_disconnect              : QtWidgets.QPushButton = None
        self.pushButton_read                    : QtWidgets.QPushButton = None
        self.pushButton_write                   : QtWidgets.QPushButton = None
        self.pushButton_graph_reset             : QtWidgets.QPushButton = None
        self.pushButton_graph_load             : QtWidgets.QPushButton = None
        self.lineEdit_ip                        : QtWidgets.QLineEdit   = None
        self.lineEdit_port                      : QtWidgets.QLineEdit   = None
        self.spinBox_trigger_level              : QtWidgets.QSpinBox    = None
        self.spinBox_trigger_delay              : QtWidgets.QSpinBox    = None
        self.spinBox_trigger_clearance          : QtWidgets.QSpinBox    = None
        self.spinBox_photon1                    : QtWidgets.QSpinBox    = None
        self.spinBox_photon2                    : QtWidgets.QSpinBox    = None
        self.spinBox_photon3                    : QtWidgets.QSpinBox    = None
        self.spinBox_photon4                    : QtWidgets.QSpinBox    = None
        self.spinBox_photon5                    : QtWidgets.QSpinBox    = None
        self.spinBox_photon6                    : QtWidgets.QSpinBox    = None
        self.spinBox_photon7                    : QtWidgets.QSpinBox    = None
        self.spinBox_photon8                    : QtWidgets.QSpinBox    = None
        self.horizontalSlider_trigger_level     : QtWidgets.QSlider     = None

        self.label_trigger_level_display        : QtWidgets.QLabel      = None
        self.label_trigger_delay_display        : QtWidgets.QLabel      = None
        self.label_trigger_clearance_display    : QtWidgets.QLabel      = None
        self.label_photon1_display              : QtWidgets.QLabel      = None
        self.label_photon2_display              : QtWidgets.QLabel      = None
        self.label_photon3_display              : QtWidgets.QLabel      = None
        self.label_photon4_display              : QtWidgets.QLabel      = None
        self.label_photon5_display              : QtWidgets.QLabel      = None
        self.label_photon6_display              : QtWidgets.QLabel      = None
        self.label_photon7_display              : QtWidgets.QLabel      = None
        self.label_photon8_display              : QtWidgets.QLabel      = None
        self.label_graph_samples                : QtWidgets.QLabel      = None

        self.graph_container                    : QtWidgets.QGridLayout = None

        self.groupBox_controll                  : QtWidgets.QGroupBox   = None
        self.groupBox_trigger_level             : QtWidgets.QGroupBox   = None
        self.groupBox_timing_controll           : QtWidgets.QGroupBox   = None
        self.groupBox_misc_config               : QtWidgets.QGroupBox   = None
        self.groupBox_threshold                 : QtWidgets.QGroupBox   = None
        self.groupBox_graph_control             : QtWidgets.QGroupBox   = None

        self.checkBox_trig_pos_edge             : QtWidgets.QCheckBox   = None
        self.checkBox_trig_is_a                 : QtWidgets.QCheckBox   = None
        self.checkBox_pnr_sig_inverse           : QtWidgets.QCheckBox   = None

    def attach_graph(self):
        self.graph = graph_view(self) #pg.GraphicsLayoutWidget(show=True)
        self.graph_container.addWidget(self.graph)

    def toggle_config_input(self, bool):
        self.groupBox_controll.setEnabled(bool)
        self.groupBox_trigger_level.setEnabled(bool)
        self.groupBox_timing_controll.setEnabled(bool)
        self.groupBox_misc_config.setEnabled(bool)
        self.groupBox_threshold.setEnabled(bool)
        self.groupBox_graph_control.setEnabled(bool)

    def push_connect(self):
        try:
            self.scpi_mannager = SCPI_mannager(host=self.lineEdit_ip.text().strip(), port=int(self.lineEdit_port.text()))
            result = self.scpi_mannager.idn()
            if result == None: raise Exception('fail for IDN')
            self.pushButton_connect.setEnabled(False)
            self.pushButton_disconnect.setEnabled(True)
            self.toggle_config_input(True)
        except Exception as e:
            print(e)
            pass


    def push_disconnect(self):
        self.pushButton_disconnect.setEnabled(False)
        self.pushButton_connect.setEnabled(True)
        self.toggle_config_input(False)
        self.scpi_mannager: SCPI_mannager = None

    def display_value(self):
        gen_time = lambda x: f'= {8*x} ns'
        gen_volt = lambda x: f'= {x/8.192:.5g} mv'
        
        self.label_trigger_level_display.setText(gen_volt(self.spinBox_trigger_level.value()))
        self.label_trigger_delay_display.setText(gen_time(self.spinBox_trigger_delay.value()))
        self.label_trigger_clearance_display.setText(gen_time(self.spinBox_trigger_clearance.value()))
        self.label_photon1_display.setText(gen_volt(self.spinBox_photon1.value()))
        self.label_photon2_display.setText(gen_volt(self.spinBox_photon2.value()))
        self.label_photon3_display.setText(gen_volt(self.spinBox_photon3.value()))
        self.label_photon4_display.setText(gen_volt(self.spinBox_photon4.value()))
        self.label_photon5_display.setText(gen_volt(self.spinBox_photon5.value()))
        self.label_photon6_display.setText(gen_volt(self.spinBox_photon6.value()))
        self.label_photon7_display.setText(gen_volt(self.spinBox_photon7.value()))
        self.label_photon8_display.setText(gen_volt(self.spinBox_photon8.value()))

        value_dict = {
            'photon1':self.spinBox_photon1.value(),
            'photon2':self.spinBox_photon2.value(),
            'photon3':self.spinBox_photon3.value(),
            'photon4':self.spinBox_photon4.value(),
            'photon5':self.spinBox_photon5.value(),
            'photon6':self.spinBox_photon6.value(),
            'photon7':self.spinBox_photon7.value(),
            'photon8':self.spinBox_photon8.value()
        }
        self.graph.photon_threshold_set(value_dict)

    def push_read(self):
        self.spinBox_trigger_level.setValue(self.scpi_mannager.read_trigger_level())
        self.spinBox_trigger_delay.setValue(self.scpi_mannager.read_trigger_delay())
        self.spinBox_trigger_clearance.setValue(self.scpi_mannager.read_trigger_clearance())
        self.spinBox_photon1.setValue(self.scpi_mannager.read_photon_threshold(1))
        self.spinBox_photon2.setValue(self.scpi_mannager.read_photon_threshold(2))
        self.spinBox_photon3.setValue(self.scpi_mannager.read_photon_threshold(3))
        self.spinBox_photon4.setValue(self.scpi_mannager.read_photon_threshold(4))
        self.spinBox_photon5.setValue(self.scpi_mannager.read_photon_threshold(5))
        self.spinBox_photon6.setValue(self.scpi_mannager.read_photon_threshold(6))
        self.spinBox_photon7.setValue(self.scpi_mannager.read_photon_threshold(7))
        self.spinBox_photon8.setValue(self.scpi_mannager.read_photon_threshold(8))
        self.checkBox_pnr_sig_inverse.setChecked(self.scpi_mannager.read_pnr_sig_inverse())
        self.checkBox_trig_pos_edge.setChecked(self.scpi_mannager.read_trig_positive_edge())
        self.checkBox_trig_is_a.setChecked(self.scpi_mannager.read_trig_is_a())


    def push_write(self):
        self.scpi_mannager.set_trigger_level(self.spinBox_trigger_level.value())
        self.scpi_mannager.set_trigger_delay(self.spinBox_trigger_delay.value())
        self.scpi_mannager.set_trigger_clearance(self.spinBox_trigger_clearance.value())
        self.scpi_mannager.set_photon_threshold(1, self.spinBox_photon1.value())
        self.scpi_mannager.set_photon_threshold(2, self.spinBox_photon2.value())
        self.scpi_mannager.set_photon_threshold(3, self.spinBox_photon3.value())
        self.scpi_mannager.set_photon_threshold(4, self.spinBox_photon4.value())
        self.scpi_mannager.set_photon_threshold(5, self.spinBox_photon5.value())
        self.scpi_mannager.set_photon_threshold(6, self.spinBox_photon6.value())
        self.scpi_mannager.set_photon_threshold(7, self.spinBox_photon7.value())
        self.scpi_mannager.set_photon_threshold(8, self.spinBox_photon8.value())
        self.scpi_mannager.set_pnr_sig_inverse(self.checkBox_pnr_sig_inverse.isChecked())
        self.scpi_mannager.set_trig_positive_edge(self.checkBox_trig_pos_edge.isChecked())
        self.scpi_mannager.set_trig_is_a(self.checkBox_trig_is_a.isChecked())

    def push_graph_reset(self):
        self.graph.reset_graph()
        self.scpi_mannager.reset_adc_fifo()
        self.label_graph_samples.setText(f'Samples:{len(self.graph.vals)}')

    def push_graph_load(self):
        array = self.scpi_mannager.read_pnr_adc_fifo()
        self.graph.append_data(array)
        self.label_graph_samples.setText(f'Samples:{len(self.graph.vals)}')

    
    def photon_threshold_set(self, value_dict: dict):
        assert len(value_dict) == 8
        self.spinBox_photon1.setValue(value_dict['photon1'])
        self.spinBox_photon2.setValue(value_dict['photon2'])
        self.spinBox_photon3.setValue(value_dict['photon3'])
        self.spinBox_photon4.setValue(value_dict['photon4'])
        self.spinBox_photon5.setValue(value_dict['photon5'])
        self.spinBox_photon6.setValue(value_dict['photon6'])
        self.spinBox_photon7.setValue(value_dict['photon7'])
        self.spinBox_photon8.setValue(value_dict['photon8'])





        
        

