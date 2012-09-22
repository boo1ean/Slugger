#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QtGui/QGraphicsView>

QT_BEGIN_NAMESPACE
class QPushButton;
class QTcpServer;
class QNetworkSession;
class QTcpSocket;
QT_END_NAMESPACE

class MainWindow : public QGraphicsView
{
    Q_OBJECT
    
public:
    MainWindow(QWidget *parent = 0);
    ~MainWindow();

private slots:
    void startServer();
    void sessionOpened();
    void startConnection();
    void moveRect();

private:
    float * a;

    QTcpSocket        * clientConnection;
    QGraphicsScene    * scene;
    QPushButton       * button;
    QGraphicsRectItem * rect;

    QTcpServer      * tcpServer;
    QNetworkSession * networkSession;
};

#endif // MAINWINDOW_H
