#include "mainwindow.h"

#include <QtGui>
#include <QPushButton>
#include <QtNetwork>
#include <QtEndian>

#define DEFAULT_PORT 9595

MainWindow::MainWindow(QWidget *parent)
  : QGraphicsView(parent)
{
  scene = new QGraphicsScene(100, 100, 100, 100);
  scene->setBackgroundBrush(Qt::white);

  button = new QPushButton("Start server");
  button->resize(200, 200);

  scene->addWidget(button);

  setScene(scene);

  connect(button, SIGNAL(clicked()), this, SLOT(startServer()));
}

void MainWindow::startServer()
{
  button->hide();

  rect = scene->addRect(100, 100, 100, 100);
  rect->setBrush(Qt::black);


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

    setWindowTitle(tr("Air Play"));
}

MainWindow::~MainWindow()
{
  
}


void MainWindow::sessionOpened()
{
  // Save the used configuration
  if (networkSession) {
    QNetworkConfiguration config = networkSession->configuration();
    QString id;
    if (config.type() == QNetworkConfiguration::UserChoice)
      id = networkSession->sessionProperty(QLatin1String("UserChoiceConfiguration")).toString();
    else
      id = config.identifier();

    QSettings settings(QSettings::UserScope, QLatin1String("Trolltech"));
    settings.beginGroup(QLatin1String("QtNetwork"));
    settings.setValue(QLatin1String("DefaultNetworkConfiguration"), id);
    settings.endGroup();
  }

  tcpServer = new QTcpServer(this);
  if (!tcpServer->listen(QHostAddress::Any, DEFAULT_PORT)) {
    QMessageBox::critical(this, tr("Slugger Server"),
                tr("Unable to start the server: %1.")
                .arg(tcpServer->errorString()));
    close();
    return;
  }

  QString ipAddress;
  QList<QHostAddress> ipAddressesList = QNetworkInterface::allAddresses();
  // use the first non-localhost IPv4 address
  for (int i = 0; i < ipAddressesList.size(); ++i) {
    if (ipAddressesList.at(i) != QHostAddress::LocalHost &&
      ipAddressesList.at(i).toIPv4Address()) {
      ipAddress = ipAddressesList.at(i).toString();
      break;
    }
  }
  // if we did not find one, use IPv4 localhost
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
      this, SLOT(moveRect()));
}

void MainWindow::moveRect()
{
  QByteArray data = clientConnection->readAll();

  // Now you have floats in LE (converted to LE on devices)

  #if Q_BYTE_ORDER == Q_BIG_ENDIAN

  #else

  #endif

  /**
   * Here you can use rect->moveBy(x, y) to move rect.
   */
}
