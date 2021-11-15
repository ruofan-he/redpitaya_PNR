import sys
import os
from PyQt5 import QtWidgets, uic, QtCore
import pyqtgraph as pg
import numpy as np
from ..communication import SCPI_mannager


class graph_view(pg.GraphicsLayoutWidget):
    def __init__(self):
        super().__init__(show=True)
        plt1 = self.addPlot()
        vals = np.random.normal(size=10000)
        y,x = np.histogram(vals, bins=np.linspace(-5, 5, 100))
        plt1.plot(x, y, stepMode="center", fillLevel=0, fillOutline=True, brush=(0,0,255,150))
        



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

        

        
            


    def ui_components(self):
        # just type hint
        self.graph_container                    : QtWidgets.QGridLayout = None
        self.pushButton_connect                 : QtWidgets.QPushButton = None
        self.pushButton_disconnect              : QtWidgets.QPushButton = None
        self.pushButton_read                    : QtWidgets.QPushButton = None
        self.pushButton_write                   : QtWidgets.QPushButton = None
        self.lineEdit_ip                        : QtWidgets.QLineEdit   = None
        self.lineEdit_port                      : QtWidgets.QLineEdit   = None
        self.spinBox_trigger_level              : QtWidgets.QSpinBox    = None
        self.spinBox_trigger_delay              : QtWidgets.QSpinBox    = None
        self.spinBox_trigger_clearance         : QtWidgets.QSpinBox    = None
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
        self.label_trigger_clearance_display   : QtWidgets.QLabel      = None
        self.label_photon1_display              : QtWidgets.QLabel      = None
        self.label_photon2_display              : QtWidgets.QLabel      = None
        self.label_photon3_display              : QtWidgets.QLabel      = None
        self.label_photon4_display              : QtWidgets.QLabel      = None
        self.label_photon5_display              : QtWidgets.QLabel      = None
        self.label_photon6_display              : QtWidgets.QLabel      = None
        self.label_photon7_display              : QtWidgets.QLabel      = None
        self.label_photon8_display              : QtWidgets.QLabel      = None

        self.graph_container                    : QtWidgets.QGridLayout = None

        self.groupBox_controll                  : QtWidgets.QGroupBox   = None
        self.groupBox_trigger_level             : QtWidgets.QGroupBox   = None
        self.groupBox_timing_controll           : QtWidgets.QGroupBox   = None
        self.groupBox_threshold                 : QtWidgets.QGroupBox   = None

    def attach_graph(self):
        win = graph_view() #pg.GraphicsLayoutWidget(show=True)
        self.graph_container.addWidget(win)

    def toggle_config_input(self, bool):
        self.groupBox_controll.setEnabled(bool)
        self.groupBox_trigger_level.setEnabled(bool)
        self.groupBox_timing_controll.setEnabled(bool)
        self.groupBox_threshold.setEnabled(bool)

    def push_connect(self):
        try:
            self.scpi_mannager = SCPI_mannager(host=self.lineEdit_ip.text().strip(), port=int(self.lineEdit_port.text()))
            self.scpi_mannager.idn()
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



        
        

