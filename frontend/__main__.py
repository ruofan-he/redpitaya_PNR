import sys
from PyQt5 import QtWidgets, QtCore
from .top import Top_window

def main():
    QtWidgets.QApplication.setAttribute(QtCore.Qt.AA_EnableHighDpiScaling, True) #enable highdpi scaling
    QtWidgets.QApplication.setAttribute(QtCore.Qt.AA_UseHighDpiPixmaps, True) #use highdpi icons
    app = QtWidgets.QApplication(sys.argv)
    top = Top_window()
    top.show()
    app.exec()


if __name__ == '__main__':
    main()
