 //
 // A note from Brandon Fosdick, one of the QExtSerialPort developers,
 // to Wes Hardaker states:
 //
 // qesp doesn't really have a license, it's considered completely public
 // domain.
 //
 
 #include <stdio.h>
 //#include <QDebug>
 #include "qextserialport.h"
 
 QextSerialPort::QextSerialPort(QextSerialPort::QueryMode mode)
  : QIODevice()
 {
 
 #ifdef Q_OS_WIN
     setPortName("COM1");
 
 #elif defined(_TTY_IRIX_)
     setPortName("/dev/ttyf1");
 
 #elif defined(_TTY_HPUX_)
     setPortName("/dev/tty1p0");
 
 #elif defined(_TTY_SUN_)
     setPortName("/dev/ttya");
 
 #elif defined(_TTY_DIGITAL_)
     setPortName("/dev/tty01");
 
 #elif defined(_TTY_FREEBSD_)
     setPortName("/dev/ttyd1");
 
 #elif defined(_TTY_OPENBSD_)
     setPortName("/dev/tty00");
 
 #else
     setPortName("/dev/ttyS0");
 #endif
 
     construct();
     setQueryMode(mode);
     platformSpecificInit();
 }
 
 QextSerialPort::QextSerialPort(const QString & name, QextSerialPort::QueryMode mode)
     : QIODevice()
 {
     construct();
     setQueryMode(mode);
     setPortName(name);
     platformSpecificInit();
 }
 
 QextSerialPort::QextSerialPort(const PortSettings& settings, QextSerialPort::QueryMode mode)
     : QIODevice()
 {
     construct();
     setBaudRate(settings.BaudRate);
     setDataBits(settings.DataBits);
     setParity(settings.Parity);
     setStopBits(settings.StopBits);
     setFlowControl(settings.FlowControl);
     setTimeout(settings.Timeout_Millisec);
     setQueryMode(mode);
     platformSpecificInit();
 }
 
 QextSerialPort::QextSerialPort(const QString & name, const PortSettings& settings, QextSerialPort::QueryMode mode)
     : QIODevice()
 {
     construct();
     setPortName(name);
     setBaudRate(settings.BaudRate);
     setDataBits(settings.DataBits);
     setParity(settings.Parity);
     setStopBits(settings.StopBits);
     setFlowControl(settings.FlowControl);
     setTimeout(settings.Timeout_Millisec);
     setQueryMode(mode);
     platformSpecificInit();
 }
 
 void QextSerialPort::construct()
 {
     lastErr = E_NO_ERROR;
     Settings.BaudRate=BAUD115200;
     Settings.DataBits=DATA_8;
     Settings.Parity=PAR_NONE;
     Settings.StopBits=STOP_1;
     Settings.FlowControl=FLOW_HARDWARE;
     Settings.Timeout_Millisec=500;
     //mutex = new QMutex( QMutex::Recursive );
     setOpenMode(QIODevice::NotOpen);
 }
 
 void QextSerialPort::setQueryMode(QueryMode mechanism)
 {
     _queryMode = mechanism;
 }
 
 void QextSerialPort::setPortName(const QString & name)
 {
     //#ifdef Q_OS_WIN
     //port = fullPortNameWin( name );
     //#else
     port = name;
    // #endif
 }
 
 QString QextSerialPort::portName() const
 {
     return port;
 }
 
 QByteArray QextSerialPort::readAll()
 {
     int avail = this->bytesAvailable();
     QByteArray received;
     //qDebug() << "=============== avail = " << avail << " QIODevice::bytesAvailable() " << QIODevice::bytesAvailable();
     if(avail > 0)
     {
         received = this->read(avail);
         //qDebug()<<"22222 readAll :"<<received.toHex()<<" lengh = "<<received.length();

     }
     //return (avail > 0) ? received : QByteArray();
     return received;
 }
 
 BaudRateType QextSerialPort::baudRate(void) const
 {
     return Settings.BaudRate;
 }
 
 DataBitsType QextSerialPort::dataBits() const
 {
     return Settings.DataBits;
 }
 
 ParityType QextSerialPort::parity() const
 {
     return Settings.Parity;
 }
 
 StopBitsType QextSerialPort::stopBits() const
 {
     return Settings.StopBits;
 }
 
 FlowType QextSerialPort::flowControl() const
 {
     return Settings.FlowControl;
 }
 
 bool QextSerialPort::isSequential() const
 {
     return true;
 }
 
 QString QextSerialPort::errorString()
 {
     switch(lastErr)
     {
         case E_NO_ERROR: return "No Error has occurred";
         case E_INVALID_FD: return "Invalid file descriptor (port was not opened correctly)";
         case E_NO_MEMORY: return "Unable to allocate memory tables (POSIX)";
         case E_CAUGHT_NON_BLOCKED_SIGNAL: return "Caught a non-blocked signal (POSIX)";
         case E_PORT_TIMEOUT: return "Operation timed out (POSIX)";
         case E_INVALID_DEVICE: return "The file opened by the port is not a valid device";
         case E_BREAK_CONDITION: return "The port detected a break condition";
         case E_FRAMING_ERROR: return "The port detected a framing error (usually caused by incorrect baud rate settings)";
         case E_IO_ERROR: return "There was an I/O error while communicating with the port";
         case E_BUFFER_OVERRUN: return "Character buffer overrun";
         case E_RECEIVE_OVERFLOW: return "Receive buffer overflow";
         case E_RECEIVE_PARITY_ERROR: return "The port detected a parity error in the received data";
         case E_TRANSMIT_OVERFLOW: return "Transmit buffer overflow";
         case E_READ_FAILED: return "General read operation failure";
         case E_WRITE_FAILED: return "General write operation failure";
         case E_FILE_NOT_FOUND: return "The "+this->portName()+" file doesn't exists";
         default: return QString("Unknown error: %1").arg(lastErr);
     }
 }
 
 QextSerialPort::~QextSerialPort()
 {
     if (isOpen()) {
         close();
     }
     platformSpecificDestruct();
     //delete mutex;
 }

//#include "qextserialport.moc"
