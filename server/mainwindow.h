#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QtGui/QGraphicsView>

QT_BEGIN_NAMESPACE
class QPushButton;
class QTcpServer;
class QNetworkSession;
class QTcpSocket;
class QTimeLine;
class QGraphicsItemAnimation;
QT_END_NAMESPACE

class MainWindow : public QGraphicsView
{
    Q_OBJECT

public:
    MainWindow(QWidget *parent = 0);
    ~MainWindow();

signals:
    void updateRect(QRectF);

private slots:
    void startServer();
    void sessionOpened();
    void startConnection();
    void moveRect();
    void bounceBall();

    void greatings();

private:
    float * a;
    unsigned halfWidth;
    unsigned halfHeight;

    QTcpSocket          * clientConnection;
    QGraphicsScene      * scene;
    QGraphicsRectItem   * rect;
    QGraphicsPixmapItem * ball;

    QTimeLine              * timer;
    QGraphicsItemAnimation * animation;

    QTcpServer      * tcpServer;
    QNetworkSession * networkSession;
};

#endif // MAINWINDOW_H
