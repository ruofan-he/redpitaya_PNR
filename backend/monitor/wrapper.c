#include "/usr/include/python3.5/Python.h" 
// c wrapper for python, based on https://tanakatarou.tech/261/#toc5


extern unsigned long read_value(addr);

PyObject* f_read_value(PyObject* self, PyObject* args)
{
    unsigned long addr;
    unsigned long result;

    if (!PyArg_ParseTuple(args, "k", &addr))
        return NULL;

    result = read_value(addr);
    return Py_BuildValue("k", result);
}


extern void write_value(addr, val);

PyObject* f_write_value(PyObject* self, PyObject* args)
{
    unsigned long addr;
    unsigned long val;

    if (!PyArg_ParseTuple(args, "kk", &addr, &val))
        return NULL;
    write_value(addr, val);
    return Py_BuildValue("");
}

static PyMethodDef methods[] = {
    {"read_value" , f_read_value , METH_VARARGS},
    {"write_value", f_write_value, METH_VARARGS},
    {NULL}
};

static struct PyModuleDef module_name =
{
    PyModuleDef_HEAD_INIT,
    "monitor_wrapper",
    "",
    -1,
    methods
};

PyMODINIT_FUNC PyInit_monitor_wrapper(void)
{
    return PyModule_Create(&module_name);
}