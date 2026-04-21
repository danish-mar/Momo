#ifndef TERMINALMANAGER_H
#define TERMINALMANAGER_H

#include <QObject>
#include <QProcess>
#include <QString>
#include <QVariantList>
#include <QVariantMap>
#include <memory>
#include <vector>

struct TerminalTab {
  QProcess *process = nullptr;
  QString output;
  QString title;
  int id = 0;
};

class TerminalManager : public QObject {
  Q_OBJECT
  Q_PROPERTY(QVariantList tabs READ tabs NOTIFY tabsChanged)
  Q_PROPERTY(int currentTabIndex READ currentTabIndex WRITE setCurrentTabIndex
                 NOTIFY currentTabIndexChanged)
  Q_PROPERTY(
      QString currentOutput READ currentOutput NOTIFY currentOutputChanged)

public:
  explicit TerminalManager(QObject *parent = nullptr);
  ~TerminalManager();

  Q_INVOKABLE void sendCommand(const QString &command);
  Q_INVOKABLE void newTab();
  Q_INVOKABLE void closeTab(int index);

  QVariantList tabs() const;
  int currentTabIndex() const;
  void setCurrentTabIndex(int index);
  QString currentOutput() const;

signals:
  void tabsChanged();
  void currentTabIndexChanged();
  void currentOutputChanged();

private slots:
  void onReadyRead();

private:
  void spawnShell(TerminalTab &tab);
  QString stripAnsi(const QString &text);

  std::vector<TerminalTab> m_tabs;
  int m_currentIndex = -1;
  int m_nextId = 0;
};

#endif // TERMINALMANAGER_H