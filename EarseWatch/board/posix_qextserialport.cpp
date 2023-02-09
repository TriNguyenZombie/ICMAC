//
 // A note from Brandon Fosdick, one of the QExtSerialPort developers,
 // to Wes Hardaker states:
 //
 // qesp doesn't really have a license, it's considered completely public
 // domain.
 //
 
 #include <fcntl.h>
 #include <stdio.h>
 #include "qextserialport.h"
// #include <QtCore/QMutexLocker>
// #include <QtCore/QDebug>
#ifdef HAVE_SYS_FILIO_H
 #include <sys/filio.h>
 #endif /* HAVE_SYS_FILIO_H */
 
 void QextSerialPort::platformSpecificInit()
 {
     fd = 0;
     //readNotifier = 0;
 }
 
 void QextSerialPort::platformSpecificDestruct()
 {}
 
 void QextSerialPort::setBaudRate(BaudRateType baudRate)
 {
     // QMutexLocker lock(mutex);
     if (Settings.BaudRate!=baudRate) {
         switch (baudRate) {
             case BAUD14400:
                 Settings.BaudRate=BAUD9600;
                 break;
 
             case BAUD56000:
                 Settings.BaudRate=BAUD38400;
                 break;
 
             case BAUD76800:
 
 #ifndef B76800
                 Settings.BaudRate=BAUD57600;
 #else
                 Settings.BaudRate=baudRate;
 #endif
                 break;
 
             case BAUD128000:
             case BAUD256000:
                 Settings.BaudRate=BAUD115200;
                 break;
 
             default:
                 Settings.BaudRate=baudRate;
                 break;
         }
     }
     if (isOpen()) {
         switch (baudRate) {
 
             /*50 baud*/
             case BAUD50:
                 TTY_PORTABILITY_WARNING("QextSerialPort Portability Warning: Windows does not support 50 baud operation.");
 #ifdef CBAUD
                 Posix_CommConfig.c_cflag&=(~CBAUD);
                 Posix_CommConfig.c_cflag|=B50;
 #else
                 cfsetispeed(&Posix_CommConfig, B50);
                 cfsetospeed(&Posix_CommConfig, B50);
 #endif
                 break;
 
             /*75 baud*/
             case BAUD75:
                 TTY_PORTABILITY_WARNING("QextSerialPort Portability Warning: Windows does not support 75 baud operation.");
 #ifdef CBAUD
                 Posix_CommConfig.c_cflag&=(~CBAUD);
                 Posix_CommConfig.c_cflag|=B75;
 #else
                 cfsetispeed(&Posix_CommConfig, B75);
                 cfsetospeed(&Posix_CommConfig, B75);
 #endif
                 break;
 
             /*110 baud*/
             case BAUD110:
 #ifdef CBAUD
                 Posix_CommConfig.c_cflag&=(~CBAUD);
                 Posix_CommConfig.c_cflag|=B110;
 #else
                 cfsetispeed(&Posix_CommConfig, B110);
                 cfsetospeed(&Posix_CommConfig, B110);
 #endif
                 break;
 
             /*134.5 baud*/
             case BAUD134:
                 TTY_PORTABILITY_WARNING("QextSerialPort Portability Warning: Windows does not support 134.5 baud operation.");
 #ifdef CBAUD
                 Posix_CommConfig.c_cflag&=(~CBAUD);
                 Posix_CommConfig.c_cflag|=B134;
 #else
                 cfsetispeed(&Posix_CommConfig, B134);
                 cfsetospeed(&Posix_CommConfig, B134);
 #endif
                 break;
 
             /*150 baud*/
             case BAUD150:
                 TTY_PORTABILITY_WARNING("QextSerialPort Portability Warning: Windows does not support 150 baud operation.");
 #ifdef CBAUD
                 Posix_CommConfig.c_cflag&=(~CBAUD);
                 Posix_CommConfig.c_cflag|=B150;
 #else
                 cfsetispeed(&Posix_CommConfig, B150);
                 cfsetospeed(&Posix_CommConfig, B150);
 #endif
                 break;
 
             /*200 baud*/
             case BAUD200:
                 TTY_PORTABILITY_WARNING("QextSerialPort Portability Warning: Windows does not support 200 baud operation.");
 #ifdef CBAUD
                 Posix_CommConfig.c_cflag&=(~CBAUD);
                 Posix_CommConfig.c_cflag|=B200;
 #else
                 cfsetispeed(&Posix_CommConfig, B200);
                 cfsetospeed(&Posix_CommConfig, B200);
 #endif
                 break;
 
             /*300 baud*/
             case BAUD300:
 #ifdef CBAUD
                 Posix_CommConfig.c_cflag&=(~CBAUD);
                 Posix_CommConfig.c_cflag|=B300;
 #else                 cfsetispeed(&Posix_CommConfig, B300);
                 cfsetospeed(&Posix_CommConfig, B300);
 #endif
                 break;
 
             /*600 baud*/
             case BAUD600:
 #ifdef CBAUD
                 Posix_CommConfig.c_cflag&=(~CBAUD);
                 Posix_CommConfig.c_cflag|=B600;
 #else
                 cfsetispeed(&Posix_CommConfig, B600);
                 cfsetospeed(&Posix_CommConfig, B600);
 #endif
                 break;
 
             /*1200 baud*/
             case BAUD1200:
 #ifdef CBAUD
                 Posix_CommConfig.c_cflag&=(~CBAUD);
                 Posix_CommConfig.c_cflag|=B1200;
 #else
                 cfsetispeed(&Posix_CommConfig, B1200);
                 cfsetospeed(&Posix_CommConfig, B1200);
 #endif
                 break;
 
             /*1800 baud*/
             case BAUD1800:
                 TTY_PORTABILITY_WARNING("QextSerialPort Portability Warning: Windows and IRIX do not support 1800 baud operation.");
 #ifdef CBAUD
                 Posix_CommConfig.c_cflag&=(~CBAUD);
                 Posix_CommConfig.c_cflag|=B1800;
 #else
                 cfsetispeed(&Posix_CommConfig, B1800);
                 cfsetospeed(&Posix_CommConfig, B1800);
 #endif
                 break;
 
             /*2400 baud*/
             case BAUD2400:
 #ifdef CBAUD
                 Posix_CommConfig.c_cflag&=(~CBAUD);
                 Posix_CommConfig.c_cflag|=B2400;
 #else
                 cfsetispeed(&Posix_CommConfig, B2400);
                 cfsetospeed(&Posix_CommConfig, B2400);
 #endif
                 break;
 
             /*4800 baud*/
             case BAUD4800:
 #ifdef CBAUD
                 Posix_CommConfig.c_cflag&=(~CBAUD);
                 Posix_CommConfig.c_cflag|=B4800;
 #else
                 cfsetispeed(&Posix_CommConfig, B4800);
                 cfsetospeed(&Posix_CommConfig, B4800);
 #endif
                 break;
 
             /*9600 baud*/
             case BAUD9600:
 #ifdef CBAUD
                 Posix_CommConfig.c_cflag&=(~CBAUD);
                 Posix_CommConfig.c_cflag|=B9600;
 #else
                 cfsetispeed(&Posix_CommConfig, B9600);
                 cfsetospeed(&Posix_CommConfig, B9600);
 #endif
                 break;
 
             /*14400 baud*/
             case BAUD14400:
                 TTY_WARNING("QextSerialPort: POSIX does not support 14400 baud operation.  Switching to 9600 baud.");
 #ifdef CBAUD
                 Posix_CommConfig.c_cflag&=(~CBAUD);
                 Posix_CommConfig.c_cflag|=B9600;
 #else
                 cfsetispeed(&Posix_CommConfig, B9600);
                 cfsetospeed(&Posix_CommConfig, B9600);
 #endif
                 break;
 
             /*19200 baud*/
             case BAUD19200:
 #ifdef CBAUD
                 Posix_CommConfig.c_cflag&=(~CBAUD);
                 Posix_CommConfig.c_cflag|=B19200;
 #else
                 cfsetispeed(&Posix_CommConfig, B19200);
                 cfsetospeed(&Posix_CommConfig, B19200);
 #endif
                 break;
 
             /*38400 baud*/
             case BAUD38400:
 #ifdef CBAUD
                 Posix_CommConfig.c_cflag&=(~CBAUD);
                 Posix_CommConfig.c_cflag|=B38400;
 #else
                 cfsetispeed(&Posix_CommConfig, B38400);
                 cfsetospeed(&Posix_CommConfig, B38400);
 #endif
                 break;
 
             /*56000 baud*/
             case BAUD56000:
                 TTY_WARNING("QextSerialPort: POSIX does not support 56000 baud operation.  Switching to 38400 baud.");
 #ifdef CBAUD
                 Posix_CommConfig.c_cflag&=(~CBAUD);
                 Posix_CommConfig.c_cflag|=B38400;
 #else
                 cfsetispeed(&Posix_CommConfig, B38400);
                 cfsetospeed(&Posix_CommConfig, B38400);
 #endif
                 break;
 
             /*57600 baud*/
             case BAUD57600:
 #ifdef CBAUD
                 Posix_CommConfig.c_cflag&=(~CBAUD);
                 Posix_CommConfig.c_cflag|=B57600;
 #else
                 cfsetispeed(&Posix_CommConfig, B57600);
                 cfsetospeed(&Posix_CommConfig, B57600);
 #endif
                 break;
 
             /*76800 baud*/
             case BAUD76800:
                 TTY_PORTABILITY_WARNING("QextSerialPort Portability Warning: Windows and some POSIX systems do not support 76800 baud operation.");
 #ifdef CBAUD
                 Posix_CommConfig.c_cflag&=(~CBAUD);
 
 #ifdef B76800
                 Posix_CommConfig.c_cflag|=B76800;
 #else
                 TTY_WARNING("QextSerialPort: QextSerialPort was compiled without 76800 baud support.  Switching to 57600 baud.");
                 Posix_CommConfig.c_cflag|=B57600;
 #endif //B76800
 #else  //CBAUD
 #ifdef B76800
                 cfsetispeed(&Posix_CommConfig, B76800);
                 cfsetospeed(&Posix_CommConfig, B76800);
 #else
                 TTY_WARNING("QextSerialPort: QextSerialPort was compiled without 76800 baud support.  Switching to 57600 baud.");
                 cfsetispeed(&Posix_CommConfig, B57600);
                 cfsetospeed(&Posix_CommConfig, B57600);
 #endif //B76800
 #endif //CBAUD
                 break;
 
             /*115200 baud*/
             case BAUD115200:
 #ifdef CBAUD
                 Posix_CommConfig.c_cflag&=(~CBAUD);
                 Posix_CommConfig.c_cflag|=B115200;
 #else
                 cfsetispeed(&Posix_CommConfig, B115200);
                 cfsetospeed(&Posix_CommConfig, B115200);
 #endif
                 break;
 
             /*128000 baud*/
             case BAUD128000:
                 TTY_WARNING("QextSerialPort: POSIX does not support 128000 baud operation.  Switching to 115200 baud.");
 #ifdef CBAUD
                 Posix_CommConfig.c_cflag&=(~CBAUD);
                 Posix_CommConfig.c_cflag|=B115200;
 #else
                 cfsetispeed(&Posix_CommConfig, B115200);
                 cfsetospeed(&Posix_CommConfig, B115200);
 #endif
                 break;
 
             /*256000 baud*/
             case BAUD256000:
                 TTY_WARNING("QextSerialPort: POSIX does not support 256000 baud operation.  Switching to 115200 baud.");
 #ifdef CBAUD
                 Posix_CommConfig.c_cflag&=(~CBAUD);
                 Posix_CommConfig.c_cflag|=B115200;
 #else
                 cfsetispeed(&Posix_CommConfig, B115200);
                 cfsetospeed(&Posix_CommConfig, B115200);
 #endif
                 break;
         }
         tcsetattr(fd, TCSAFLUSH, &Posix_CommConfig);
     }
 }
 
 void QextSerialPort::setDataBits(DataBitsType dataBits)
 {
     // QMutexLocker lock(mutex);
     if (Settings.DataBits!=dataBits) {
         if ((Settings.StopBits==STOP_2 && dataBits==DATA_5) ||
             (Settings.StopBits==STOP_1_5 && dataBits!=DATA_5) ||
             (Settings.Parity==PAR_SPACE && dataBits==DATA_8)) {
         }
         else {
             Settings.DataBits=dataBits;
         }
     }
     if (isOpen()) {
         switch(dataBits) {
 
             /*5 data bits*/
             case DATA_5:
                 if (Settings.StopBits==STOP_2) {
                     TTY_WARNING("QextSerialPort: 5 Data bits cannot be used with 2 stop bits.");
                 }
                 else {
                     Settings.DataBits=dataBits;
                     Posix_CommConfig.c_cflag&=(~CSIZE);
                     Posix_CommConfig.c_cflag|=CS5;
                     tcsetattr(fd, TCSAFLUSH, &Posix_CommConfig);
                 }
                 break;
 
             /*6 data bits*/
             case DATA_6:
                 if (Settings.StopBits==STOP_1_5) {
                     TTY_WARNING("QextSerialPort: 6 Data bits cannot be used with 1.5 stop bits.");
                 }
                 else {
                     Settings.DataBits=dataBits;
                     Posix_CommConfig.c_cflag&=(~CSIZE);
                     Posix_CommConfig.c_cflag|=CS6;
                     tcsetattr(fd, TCSAFLUSH, &Posix_CommConfig);
                 }
                 break;
 
             /*7 data bits*/
             case DATA_7:
                 if (Settings.StopBits==STOP_1_5) {
                     TTY_WARNING("QextSerialPort: 7 Data bits cannot be used with 1.5 stop bits.");
                 }
                 else {
                     Settings.DataBits=dataBits;
                     Posix_CommConfig.c_cflag&=(~CSIZE);
                     Posix_CommConfig.c_cflag|=CS7;
                     tcsetattr(fd, TCSAFLUSH, &Posix_CommConfig);
                 }
                 break;
 
             /*8 data bits*/
             case DATA_8:
                 if (Settings.StopBits==STOP_1_5) {
                     TTY_WARNING("QextSerialPort: 8 Data bits cannot be used with 1.5 stop bits.");
                 }
                 else {
                     Settings.DataBits=dataBits;
                     Posix_CommConfig.c_cflag&=(~CSIZE);
                     Posix_CommConfig.c_cflag|=CS8;
                     tcsetattr(fd, TCSAFLUSH, &Posix_CommConfig);
                 }
                 break;
         }
     }
 }
 
 void QextSerialPort::setParity(ParityType parity)
 {
     // QMutexLocker lock(mutex);
     if (Settings.Parity!=parity) {
         if (parity==PAR_MARK || (parity==PAR_SPACE && Settings.DataBits==DATA_8)) {
         }
         else {
             Settings.Parity=parity;
         }
     }
     if (isOpen()) {
         switch (parity) {
 
             /*space parity*/
             case PAR_SPACE:
                 if (Settings.DataBits==DATA_8) {
                     TTY_PORTABILITY_WARNING("QextSerialPort:  Space parity is only supported in POSIX with 7 or fewer data bits");
                 }
                 else {
 
                     /*space parity not directly supported - add an extra data bit to simulate it*/
                     Posix_CommConfig.c_cflag&=~(PARENB|CSIZE);
                     switch(Settings.DataBits) {
                         case DATA_5:
                             Settings.DataBits=DATA_6;
                             Posix_CommConfig.c_cflag|=CS6;
                             break;
 
                         case DATA_6:
                             Settings.DataBits=DATA_7;
                             Posix_CommConfig.c_cflag|=CS7;
                             break;
 
                         case DATA_7:
                             Settings.DataBits=DATA_8;
                             Posix_CommConfig.c_cflag|=CS8;
                             break;
 
                         case DATA_8:
                             break;
                     }
                     tcsetattr(fd, TCSAFLUSH, &Posix_CommConfig);
                 }
                 break;
 
             /*mark parity - WINDOWS ONLY*/
             case PAR_MARK:
                 TTY_WARNING("QextSerialPort: Mark parity is not supported by POSIX.");
                 break;
 
             /*no parity*/
             case PAR_NONE:
                 Posix_CommConfig.c_cflag&=(~PARENB);
                 tcsetattr(fd, TCSAFLUSH, &Posix_CommConfig);
                 break;
 
             /*even parity*/
             case PAR_EVEN:
                 Posix_CommConfig.c_cflag&=(~PARODD);
                 Posix_CommConfig.c_cflag|=PARENB;
                 tcsetattr(fd, TCSAFLUSH, &Posix_CommConfig);
                 break;
 
             /*odd parity*/
             case PAR_ODD:
                 Posix_CommConfig.c_cflag|=(PARENB|PARODD);
                 tcsetattr(fd, TCSAFLUSH, &Posix_CommConfig);
                 break;
         }
     }
 }
 
 void QextSerialPort::setStopBits(StopBitsType stopBits)
 {
     // QMutexLocker lock(mutex);
     if (Settings.StopBits!=stopBits) {
         if ((Settings.DataBits==DATA_5 && stopBits==STOP_2) || stopBits==STOP_1_5) {}
         else {
             Settings.StopBits=stopBits;
         }
     }
     if (isOpen()) {
         switch (stopBits) {
 
             /*one stop bit*/
             case STOP_1:
                 Settings.StopBits=stopBits;
                 Posix_CommConfig.c_cflag&=(~CSTOPB);
                 tcsetattr(fd, TCSAFLUSH, &Posix_CommConfig);
                 break;
 
             /*1.5 stop bits*/
             case STOP_1_5:
                 TTY_WARNING("QextSerialPort: 1.5 stop bit operation is not supported by POSIX.");
                 break;
 
             /*two stop bits*/
             case STOP_2:
                 if (Settings.DataBits==DATA_5) {
                     TTY_WARNING("QextSerialPort: 2 stop bits cannot be used with 5 data bits");
                 }
                 else {
                     Settings.StopBits=stopBits;
                     Posix_CommConfig.c_cflag|=CSTOPB;
                     tcsetattr(fd, TCSAFLUSH, &Posix_CommConfig);
                 }
                 break;
         }
     }
 }
 
 void QextSerialPort::setFlowControl(FlowType flow)
 {
     // QMutexLocker lock(mutex);
     if (Settings.FlowControl!=flow) {
         Settings.FlowControl=flow;
     }
     if (isOpen()) {
         switch(flow) {
 
             /*no flow control*/
             case FLOW_OFF:
                 Posix_CommConfig.c_cflag&=(~CRTSCTS);
                 Posix_CommConfig.c_iflag&=(~(IXON|IXOFF|IXANY));
                 tcsetattr(fd, TCSAFLUSH, &Posix_CommConfig);
                 break;
 
             /*software (XON/XOFF) flow control*/
             case FLOW_XONXOFF:
                 Posix_CommConfig.c_cflag&=(~CRTSCTS);
                 Posix_CommConfig.c_iflag|=(IXON|IXOFF|IXANY);
                 tcsetattr(fd, TCSAFLUSH, &Posix_CommConfig);
                 break;
 
             case FLOW_HARDWARE:
                 Posix_CommConfig.c_cflag|=CRTSCTS;
                 Posix_CommConfig.c_iflag&=(~(IXON|IXOFF|IXANY));
                 tcsetattr(fd, TCSAFLUSH, &Posix_CommConfig);
                 break;
         }
     }
 }
 
 void QextSerialPort::setTimeout(long millisec)
 {
     // QMutexLocker lock(mutex);
     Settings.Timeout_Millisec = millisec;
     Posix_Copy_Timeout.tv_sec = millisec / 1000;
     Posix_Copy_Timeout.tv_usec = millisec % 1000;
     if (isOpen()) {
         if (millisec == -1)
             fcntl(fd, F_SETFL, O_NDELAY);
         else
             //O_SYNC should enable blocking ::write()
             //however this seems not working on Linux 2.6.21 (works on OpenBSD 4.2)
             fcntl(fd, F_SETFL, O_SYNC);
         tcgetattr(fd, & Posix_CommConfig);
         Posix_CommConfig.c_cc[VTIME] = millisec/100;
         tcsetattr(fd, TCSAFLUSH, & Posix_CommConfig);
     }
 }
 
 bool QextSerialPort::open(OpenMode mode)
 {
     // QMutexLocker lock(mutex);
     if (mode == QIODevice::NotOpen)
         return isOpen();
     if (!isOpen()) {
         //qDebug() << "trying to open file" << port.toAscii();
         //note: linux 2.6.21 seems to ignore O_NDELAY flag
         if ((fd = ::open(port.toAscii() ,O_RDWR | O_NOCTTY | O_NDELAY)) != -1) {
             //qDebug("file opened succesfully");
             setOpenMode(mode);              // Flag the port as opened
             tcgetattr(fd, &old_termios);    // Save the old termios
             Posix_CommConfig = old_termios; // Make a working copy

 
             /* the equivelent of cfmakeraw() to enable raw access */
 #ifdef HAVE_CFMAKERAW
             cfmakeraw(&Posix_CommConfig);   // Enable raw access
 #else
             Posix_CommConfig.c_iflag &= ~(IGNBRK | BRKINT | PARMRK | ISTRIP
                                     | INLCR | IGNCR | ICRNL | IXON);
             Posix_CommConfig.c_oflag &= ~OPOST;
             Posix_CommConfig.c_lflag &= ~(ECHO | ECHONL | ICANON | ISIG | IEXTEN);
             Posix_CommConfig.c_cflag &= ~(CSIZE | PARENB);
             Posix_CommConfig.c_cflag |= CS8;
 #endif
 
             /*set up other port settings*/
             Posix_CommConfig.c_cflag|=CREAD|CLOCAL;
             Posix_CommConfig.c_lflag&=(~(ICANON|ECHO|ECHOE|ECHOK|ECHONL|ISIG));
             Posix_CommConfig.c_iflag&=(~(INPCK|IGNPAR|PARMRK|ISTRIP|ICRNL|IXANY));
             Posix_CommConfig.c_oflag&=(~OPOST);
             Posix_CommConfig.c_cc[VMIN]= 0;
 #ifdef _POSIX_VDISABLE  // Is a disable character available on this system?
             // Some systems allow for per-device disable-characters, so get the
             //  proper value for the configured device
             const long vdisable = fpathconf(fd, _PC_VDISABLE);
             Posix_CommConfig.c_cc[VINTR] = vdisable;
             Posix_CommConfig.c_cc[VQUIT] = vdisable;
             Posix_CommConfig.c_cc[VSTART] = vdisable;
             Posix_CommConfig.c_cc[VSTOP] = vdisable;
             Posix_CommConfig.c_cc[VSUSP] = vdisable;
 #endif //_POSIX_VDISABLE
             setBaudRate(Settings.BaudRate);
             setDataBits(Settings.DataBits);
             setParity(Settings.Parity);
             setStopBits(Settings.StopBits);
             setFlowControl(Settings.FlowControl);
             setTimeout(Settings.Timeout_Millisec);
             tcsetattr(fd, TCSAFLUSH, &Posix_CommConfig);
 
             if (queryMode() == QextSerialPort::EventDriven) {
                 //readNotifier = new QSocketNotifier(fd, QSocketNotifier::Read, this);
                 //connect(readNotifier, SIGNAL(activated(int)), this, SIGNAL(readyRead()));
             }
         } else {
             qDebug() << "could not open file:" << strerror(errno);
             lastErr = E_FILE_NOT_FOUND;
         }
     }
     return isOpen();
 }
 
 void QextSerialPort::close()
 {
     // QMutexLocker lock(mutex);
     if( isOpen() )
     {
         // Force a flush and then restore the original termios
         flush();
         // Using both TCSAFLUSH and TCSANOW here discards any pending input
         tcsetattr(fd, TCSAFLUSH | TCSANOW, &old_termios);   // Restore termios
         // Be a good QIODevice and call QIODevice::close() before POSIX close()
         //  so the aboutToClose() signal is emitted at the proper time
         QIODevice::close(); // Flag the device as closed
         // QIODevice::close() doesn't actually close the port, so do that here
         ::close(fd);
         //delete readNotifier;
         //readNotifier = 0;
     }
 }
 
 void QextSerialPort::flush()
 {
     // QMutexLocker lock(mutex);
     if (isOpen())
         tcflush(fd, TCIOFLUSH);
 }
 
 qint64 QextSerialPort::size() const
 {
     int numBytes;
     if (ioctl(fd, FIONREAD, &numBytes)<0) {
         numBytes = 0;
     }
     return (qint64)numBytes;
 }
 
 qint64 QextSerialPort::bytesAvailable() const
 {
     // QMutexLocker lock(mutex);
     if (isOpen()) {
         int bytesQueued;
         if (ioctl(fd, FIONREAD, &bytesQueued) == -1) {
             return (qint64)-1;
         }
         return bytesQueued + QIODevice::bytesAvailable();
     }
     return 0;
 }
 
 void QextSerialPort::ungetChar(char)
 {
     /*meaningless on unbuffered sequential device - return error and print a warning*/
     TTY_WARNING("QextSerialPort: ungetChar() called on an unbuffered sequential device - operation is meaningless");
 }
 
 void QextSerialPort::translateError(ulong error)
 {
     switch (error) {
         case EBADF:
         case ENOTTY:
             lastErr=E_INVALID_FD;
             break;
 
         case EINTR:
             lastErr=E_CAUGHT_NON_BLOCKED_SIGNAL;
             break;
 
         case ENOMEM:
             lastErr=E_NO_MEMORY;
             break;
     }
 }
 
 void QextSerialPort::setDtr(bool set)
 {
     // QMutexLocker lock(mutex);
     if (isOpen()) {
         int status;
         ioctl(fd, TIOCMGET, &status);
         if (set) {
             status|=TIOCM_DTR;
         }
         else {
             status&=~TIOCM_DTR;
         }
         ioctl(fd, TIOCMSET, &status);
     }
 }
 
 void QextSerialPort::setRts(bool set)
 {
     // QMutexLocker lock(mutex);
     if (isOpen()) {
         int status;
         ioctl(fd, TIOCMGET, &status);
         if (set) {
             status|=TIOCM_RTS;
         }
         else {
             status&=~TIOCM_RTS;
         }
         ioctl(fd, TIOCMSET, &status);
     }
 }
 
 unsigned long QextSerialPort::lineStatus()
 {
     unsigned long Status=0, Temp=0;
     // QMutexLocker lock(mutex);
     if (isOpen()) {
         ioctl(fd, TIOCMGET, &Temp);
         if (Temp&TIOCM_CTS) {
             Status|=LS_CTS;
         }
         if (Temp&TIOCM_DSR) {
             Status|=LS_DSR;
         }
         if (Temp&TIOCM_RI) {
             Status|=LS_RI;
         }
         if (Temp&TIOCM_CD) {
             Status|=LS_DCD;
         }
         if (Temp&TIOCM_DTR) {
             Status|=LS_DTR;
         }
         if (Temp&TIOCM_RTS) {
             Status|=LS_RTS;
         }
         if (Temp&TIOCM_ST) {
             Status|=LS_ST;
         }
         if (Temp&TIOCM_SR) {
             Status|=LS_SR;
         }
     }
     return Status;
 }
 
 qint64 QextSerialPort::readData(char * data, qint64 maxSize)
 {
     // QMutexLocker lock(mutex);
     int retVal = ::read(fd, data, maxSize);
     if (retVal == -1)
         lastErr = E_READ_FAILED;
 
     return retVal;
 }
 
 qint64 QextSerialPort::writeData(const char * data, qint64 maxSize)
 {
     // QMutexLocker lock(mutex);
     int retVal =::write(fd, data, maxSize);
     if (retVal == -1)
        lastErr = E_WRITE_FAILED;
 
     return (qint64)retVal;
 }
