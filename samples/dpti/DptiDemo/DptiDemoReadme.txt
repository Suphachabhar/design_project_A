Module Description:
    The DptiDemo demonstrates how to transfer data to and from a Digilent
    FPGA board using the DPTI module of the Adept SDK.


Required Hardware:
    This demonstration requires a Digilent FPGA board that implements an
    Adept Programming Port with support for the DPTI interface.
    Additionally, the FPGA must implement a design that includes logic for
    interfacing with the asynchronous or synchronous DPTI port.
    
    At the time of writing two Digilent System Boards support DPTI: the
    Genesys 2 and the Nexys Video. To determine if DPTI is supported by a
    specific board, please see the documentation associated with that
    product.

    Note the -p option typically is used to indicate whether an
    asynchronous or synchronous interface is present in logic. On the
    Genesys2 and NexysVideo, set this to 1 for a synchronous interface, and
    0 for an asynchronous interface. The provided HDL implements a
    synchronous interface. For more information on DPTI ports, refer to the
    document titled "Digilent Adept Parallel Interface (DPTI) Programmer’s
    Reference Manual".

Supported Command Line Options:
    -d           Specify the device user name or alias.
    
    -c           Specify the number of bytes to be transferred. If this
                 parameter is omitted then a default data transfer size
                 of 10240 bytes will be used.
    
    -p           Specify the DPTI port used to perform the data transfer.
                 If this parameter is omitted then the default port
                 (Port 0) will be used to perform the data transfer.
    
    -v           Verify that the data received during the data transfer is
                 the expected data.
    
    -?, -help    Display usage, supported arguments, and options.


Example Usage:
    Executing "DptiDemo -d NexysVideo" will result in a 10240 byte data
    transfer being performed using DPTI port 0. The data received during
    the data transfer will not be verified.
    
    Executing "DptiDemo -d NexysVideo -c 10000000" will result in a
    10000000 byte data transfer being performed using DPTI port 0. The data
    received during the data transfer will not be verified.
    
    Executing "DptiDemo -d NexysVideo -c 10000000 -p 1" will result in a
    10000000 byte data transfer being performed using DPTI port 1. The data
    received during the data transfer will not be verified.
    
    Executing "DptiDemo -d NexysVideo -c 10000000 -p 1 -v" will result in a
    10000000 byte data transfer being performed using DPTI port 1. The data
    received during the data transfer will be verified.

