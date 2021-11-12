import sys
import os
from PyQt5 import QtWidgets, uic, QtCore
import pyqtgraph as pg
import numpy as np


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

    def attach_graph(self):
        win = graph_view() #pg.GraphicsLayoutWidget(show=True)
        self.graph_container.addWidget(win)

        

    
if __name__ == '__main__':
    QtWidgets.QApplication.setAttribute(QtCore.Qt.AA_EnableHighDpiScaling, True) #enable highdpi scaling
    QtWidgets.QApplication.setAttribute(QtCore.Qt.AA_UseHighDpiPixmaps, True) #use highdpi icons
    app = QtWidgets.QApplication(sys.argv)
    top = Top_window()
    top.show()
    app.exec()