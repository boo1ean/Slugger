#include "mainwindow.h"

#include <QtGui>
#include <QtNetwork>
#include <QtEndian>
#include <QtOpenGL/QGLWidget>

#define GREATINGS_TIME 1500
#define DEFAULT_PORT   9595
#define SPEED          20

enum {
    BENDY_WIDTH  = 60,
    BENDY_HEIGHT = 200
};

enum {
    BG_R = 138,
    BG_G = 199,
    BG_B = 59
};

enum {X, Y, Z};

MainWindow::MainWindow(QWidget *parent)
    : QGraphicsView(parent)
{
    scene = new QGraphicsScene;
    scene->setBackgroundBrush(Qt::white);

    setupViewport(new QGLWidget);
    setScene(scene);
    setAlignment(Qt::AlignLeft | Qt::AlignTop);
    setViewportUpdateMode(QGraphicsView::BoundingRectViewportUpdate);
    showMaximized();
    setHorizontalScrollBarPolicy(Qt::ScrollBarAlwaysOff);
    setVerticalScrollBarPolicy(Qt::ScrollBarAlwaysOff);

    startServer();
}

void MainWindow::startServer()
{
    rect = scene->addRect(0, 0, BENDY_WIDTH, BENDY_HEIGHT);
    ball = scene->addPixmap(QPixmap("ball.png"));

    halfWidth  = (width() - ball->pixmap().width()) / 2;
    halfHeight = (height() - ball->pixmap().height()) / 2;
    // Move ball to the center
    ball->setPos(halfWidth, halfHeight);

    rect->setBrush(Qt::black);
    setBackgroundBrush(QBrush(QColor(BG_R, BG_G ,BG_B)));

    timer = new QTimeLine(1000);
    connect(timer, SIGNAL(finished()), this, SLOT(bounceBall()));

    animation = new QGraphicsItemAnimation;
    animation->setItem(ball);
    animation->setTimeLine(timer);

    for (unsigned i = 0; i < halfWidth; ++i)
        animation->setPosAt(i / (qreal)halfWidth, QPointF(ball->x() - i, ball->y()));

    timer->start();

    QNetworkConfigurationManager manager;
    if (manager.capabilities() & QNetworkConfigurationManager::NetworkSessionRequired) {
        // Get saved network configuration
        QSettings settings(QSettings::UserScope, QLatin1String("Trolltech"));
        settings.beginGroup(QLatin1String("QtNetwork"));
        const QString id = settings.value(QLatin1String("DefaultNetworkConfiguration")).toString();
        settings.endGroup();

        // If the saved network configuration is not currently discovered use the system default
        QNetworkConfiguration config = manager.configurationFromIdentifier(id);
        if ((config.state() & QNetworkConfiguration::Discovered) !=
            QNetworkConfiguration::Discovered) {
            config = manager.defaultConfiguration();
        }

        networkSession = new QNetworkSession(config, this);
        connect(networkSession, SIGNAL(opened()), this, SLOT(sessionOpened()));

        networkSession->open();
    } else {
        sessionOpened();
    }

    connect(tcpServer, SIGNAL(newConnection()), this, SLOT(startConnection()));
    connect(tcpServer, SIGNAL(newConnection()), this, SLOT(greatings()));
    setWindowTitle(tr("Air Play"));
}

void MainWindow::sessionOpened()
{
    tcpServer = new QTcpServer(this);
    if (!tcpServer->listen(QHostAddress::Any, DEFAULT_PORT)) {
        QMessageBox::critical(this, tr("Slugger Server"),
            tr("Unable to start the server: %1.").arg(tcpServer->errorString()));
        close();
        return;
    }

    QString ipAddress;
    QList<QHostAddress> ipAddressesList = QNetworkInterface::allAddresses();

    // Use the first non-localhost IPv4 address
    for (int i = 0; i < ipAddressesList.size(); ++i) {
        if (ipAddressesList.at(i) != QHostAddress::LocalHost &&
            ipAddressesList.at(i).toIPv4Address()) {
            ipAddress = ipAddressesList.at(i).toString();
            break;
        }
    }

    // If we did not find one, use IPv4 localhost
    if (ipAddress.isEmpty())
        ipAddress = QHostAddress(QHostAddress::LocalHost).toString();
}

void MainWindow::startConnection()
{
    qDebug() << "Connected";

    clientConnection = tcpServer->nextPendingConnection();

    connect(clientConnection, SIGNAL(disconnected()),
            clientConnection, SLOT(deleteLater()));

    // Execute moveRect method if there is new data in socket
    connect(clientConnection, SIGNAL(readyRead()),
            this,             SLOT(moveRect()));
}

void MainWindow::moveRect()
{
    // Get x, y, z
    QByteArray data = clientConnection->readAll();
    a = (float*)data.data();

    // qDebug() << a[X] << a[Y] << a[Z];

    qDebug() << "Y: " << rect->y();

    if ((a[Y] < 0 && rect->y() < 0) || (a[Y] > 0 && (rect->y() + BENDY_HEIGHT) > height())) {
       qDebug() << "STOP";
    } else {
        rect->moveBy(0, a[Y] * SPEED);
    }
}

void MainWindow::bounceBall()
{
    qreal sign = ball->x() == halfWidth ? -1.0 : 1.0;

    qDebug() << "Bounce Ball | X: " << ball->x() << "Sign: " << sign;

    for (unsigned i = 0; i < halfWidth; ++i)
        animation->setPosAt(i / (qreal)halfWidth, QPointF(ball->x() + i * sign, ball->y()));

    timer->start();
}

void MainWindow::greatings()
{
    QGraphicsTextItem * text = scene->addText("Welcome to the game!", QFont("sans-serif", 80));
    text->setPos(200, 200);
    text->setDefaultTextColor(Qt::white);

    QTimeLine * textTimer = new QTimeLine(GREATINGS_TIME);

    QGraphicsItemAnimation * textAnimation = new QGraphicsItemAnimation;
    textAnimation->setItem(text);
    textAnimation->setTimeLine(textTimer);

    for (unsigned i = 0; i < 10; ++i)
        textAnimation->setScaleAt(i / (qreal) 10, i, i);

    connect(textTimer, SIGNAL(finished()), text, SLOT(deleteLater()));
    connect(textTimer, SIGNAL(finished()), textAnimation, SLOT(deleteLater()));
    connect(textTimer, SIGNAL(finished()), textTimer, SLOT(deleteLater()));

    textTimer->start();
}

MainWindow::~MainWindow() { }
