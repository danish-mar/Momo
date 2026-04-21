#include "TerminalManager.h"
#include <QDebug>
#include <QRegularExpression>

TerminalManager::TerminalManager(QObject *parent) : QObject(parent) {
  newTab(); // start with one tab
}

TerminalManager::~TerminalManager() {
  for (auto &tab : m_tabs) {
    if (tab.process && tab.process->state() == QProcess::Running) {
      tab.process->terminate();
      tab.process->waitForFinished(500);
    }
  }
}

void TerminalManager::spawnShell(TerminalTab &tab) {
  tab.process = new QProcess(this);
  // Merge channels so stdout+stderr come through readyReadStandardOutput
  tab.process->setProcessChannelMode(QProcess::MergedChannels);

  // TERM=dumb suppresses ANSI color/cursor codes from bash
  QProcessEnvironment env = QProcessEnvironment::systemEnvironment();
  env.insert("TERM", "dumb");
  env.insert("PS1", "$ "); // simple prompt
  tab.process->setProcessEnvironment(env);

  connect(tab.process, &QProcess::readyReadStandardOutput, this,
          &TerminalManager::onReadyRead);

  // Start a plain shell without -i to avoid ioctl errors in a non-TTY environment
  tab.process->start("/bin/bash", QStringList() << "--norc" << "--noprofile");
}

void TerminalManager::newTab() {
  m_tabs.emplace_back();
  auto &tab = m_tabs.back();
  tab.id = m_nextId++;
  tab.title = "bash " + QString::number(tab.id + 1);
  spawnShell(tab);
  emit tabsChanged();
  setCurrentTabIndex(static_cast<int>(m_tabs.size()) - 1);
}

void TerminalManager::closeTab(int index) {
  if (index < 0 || index >= static_cast<int>(m_tabs.size()))
    return;
  auto &tab = m_tabs[index];
  if (tab.process && tab.process->state() == QProcess::Running) {
    tab.process->terminate();
    tab.process->waitForFinished(500);
  }
  m_tabs.erase(m_tabs.begin() + index);
  emit tabsChanged();

  if (m_tabs.empty()) {
    newTab(); // always keep at least one
    return;
  }
  int newIdx = qBound(0, m_currentIndex, static_cast<int>(m_tabs.size()) - 1);
  m_currentIndex = -1; // force re-emit
  setCurrentTabIndex(newIdx);
}

void TerminalManager::sendCommand(const QString &command) {
  if (m_currentIndex < 0 || m_currentIndex >= static_cast<int>(m_tabs.size()))
    return;
  auto &tab = m_tabs[m_currentIndex];
  if (tab.process && tab.process->state() == QProcess::Running) {
    // Echo the command ourselves so it's visible
    tab.output += "$ " + command + "\n";
    tab.process->write(command.toUtf8() + "\n");
    emit currentOutputChanged();
  }
}

void TerminalManager::onReadyRead() {
  // Find which process fired
  QProcess *sender_proc = qobject_cast<QProcess *>(sender());
  if (!sender_proc)
    return;

  for (int i = 0; i < static_cast<int>(m_tabs.size()); ++i) {
    if (m_tabs[i].process == sender_proc) {
      QByteArray data = sender_proc->readAllStandardOutput();
      QString text = stripAnsi(QString::fromUtf8(data));
      m_tabs[i].output += text;
      // Cap at 80KB
      if (m_tabs[i].output.length() > 80000)
        m_tabs[i].output = m_tabs[i].output.right(60000);
      if (i == m_currentIndex)
        emit currentOutputChanged();
      break;
    }
  }
}

// Strip ANSI escape codes so the dumb TextArea doesn't show garbage
QString TerminalManager::stripAnsi(const QString &text) {
  static QRegularExpression ansi("\\x1B(?:[@-Z\\\\-_]|\\[[0-?]*[ -/]*[@-~])");
  QString out = text;
  out.remove(ansi);
  // Also strip carriage returns that bash --norc still emits
  out.remove('\r');
  return out;
}

QString TerminalManager::currentOutput() const {
  if (m_currentIndex < 0 || m_currentIndex >= static_cast<int>(m_tabs.size()))
    return "";
  return m_tabs[m_currentIndex].output;
}

QVariantList TerminalManager::tabs() const {
  QVariantList list;
  for (const auto &tab : m_tabs) {
    QVariantMap map;
    map["title"] = tab.title;
    map["id"] = tab.id;
    list.append(map);
  }
  return list;
}

int TerminalManager::currentTabIndex() const { return m_currentIndex; }

void TerminalManager::setCurrentTabIndex(int index) {
  if (index == m_currentIndex)
    return;
  m_currentIndex = index;
  emit currentTabIndexChanged();
  emit currentOutputChanged();
}