echo "Setup maven"
if [[ "$TRACE" == "true" ]] ; then
  echo "Tracing"
  set -x
  # Add date-time-logging
fi
CI_PROJECT_DIR=${CI_PROJECT_DIR:=$(pwd)}
MVN_SETTINGS=${MVN_SETTINGS:=~/.m2/settings.xml}
export MAVEN_ARGS="--no-transfer-progress -s $MVN_SETTINGS"
export MAVEN_OPTS="$MAVEN_OPTS -Dorg.slf4j.simpleLogger.dateTimeFormat=HH:mm:ss,SSS -Dorg.slf4j.simpleLogger.showDateTime=true"
export M2_ROOT=$CI_PROJECT_DIR/.m2
mkdir -p $M2_ROOT

cp -f $MVN_SETTINGS $M2_ROOT/settings.xml

JAVA_VERSION=$(java -version 2>&1 | awk -F[\".] '/version/ {print $2}')
if [ "$JAVA_VERSION" -ge 23 ]; then
  #WARNING: A terminally deprecated method in sun.misc.Unsafe has been called
  MAVEN_OPTS="$MAVEN_OPTS--enable-native-access=ALL-UNNAMED --sun-misc-unsafe-memory-access=allow"
fi


export MAVEN_OPTS="$MAVEN_OPTS -Dmaven.repo.local=$M2_ROOT/repository -Duser.home=./"

echo "Set up MAVEN_OPTS $MAVEN_OPTS"
print_error() {
    message=$1
    >&2 echo -e "\e[31m$message\e[0m"
}