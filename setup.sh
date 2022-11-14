#!/usr/bin/env bash

set -e

show_usage() {
  echo "Usage: $(basename $0) takes exactly 1 argument (install | uninstall)"
}

if [ $# -ne 1 ]
then
  show_usage
  exit 1
fi

check_env() {
  if [[ -z "${APM_TMP_DIR}" ]]; then
    echo "APM_TMP_DIR is not set"
    exit 1
  
  elif [[ -z "${APM_PKG_INSTALL_DIR}" ]]; then
    echo "APM_PKG_INSTALL_DIR is not set"
    exit 1
  
  elif [[ -z "${APM_PKG_BIN_DIR}" ]]; then
    echo "APM_PKG_BIN_DIR is not set"
    exit 1
  fi
}

install() {
  wget https://github.com/skylot/jadx/releases/download/v1.4.5/jadx-1.4.5.zip -O $APM_TMP_DIR/jadx-1.4.5.zip
  unzip $APM_TMP_DIR/jadx-1.4.5.zip -d $APM_PKG_INSTALL_DIR/jadx/

  wget https://github.com/adoptium/temurin18-binaries/releases/download/jdk-18.0.2%2B9/OpenJDK18U-jre_x64_linux_hotspot_18.0.2_9.tar.gz -O $APM_TMP_DIR/OpenJDK18U-jre_x64_linux_hotspot_18.0.2_9.tar.gz
  tar xf $APM_TMP_DIR/OpenJDK18U-jre_x64_linux_hotspot_18.0.2_9.tar.gz -C $APM_PKG_INSTALL_DIR

  echo "#!/usr/bin/env sh" > $APM_PKG_BIN_DIR/jadx-gui
  echo "export PATH=$APM_PKG_INSTALL_DIR/jdk-18.0.2+9-jre/bin/:\$PATH" >> $APM_PKG_BIN_DIR/jadx-gui
  echo "export JAVA_HOME=$APM_PKG_INSTALL_DIR/jdk-18.0.2+9-jre/" >> $APM_PKG_BIN_DIR/jadx-gui
  echo "$APM_PKG_INSTALL_DIR/jadx/bin/jadx-gui \"\$@\"" >> $APM_PKG_BIN_DIR/jadx-gui
  chmod +x $APM_PKG_BIN_DIR/jadx-gui
}

uninstall() {
  rm $APM_PKG_BIN_DIR/jadx-gui
  rm -rf $APM_PKG_INSTALL_DIR/jadx
  rm -rf $APM_PKG_INSTALL_DIR/jdk-18.0.2+9-jre
}

run() {
  if [[ "$1" == "install" ]]; then 
    install
  elif [[ "$1" == "uninstall" ]]; then 
    uninstall
  else
    show_usage
  fi
}

check_env
run $1