echo "Setup maven"
if [[ "$TRACE" == "true" ]] ; then
  echo "Tracing"
  set -x
  # Add date-time-logging
fi
CI_PROJECT_DIR=${CI_PROJECT_DIR:=$(pwd)}
MVN_SETTINGS=${MVN_SETTINGS:=~/.m2/settings.xml}
export MAVEN_ARGS="--no-transfer-progress"

export MAVEN_OPTS="$MAVEN_OPTS -Dorg.slf4j.simpleLogger.dateTimeFormat=HH:mm:ss,SSS -Dorg.slf4j.simpleLogger.showDateTime=true"
export M2_ROOT=$CI_PROJECT_DIR/.m2
mkdir -p $M2_ROOT

print_error() {
    message=$1
    >&2 echo -e "\e[31m$message\e[0m"
}

if [ -e "$MVN_SETTINGS" ] ; then
  cp -f $MVN_SETTINGS $M2_ROOT/settings.xml
  MAVEN_ARGS="${MAVEN_ARGS} -s $MVN_SETTINGS"
else
  print_error "Maven settings file $MVN_SETTINGS does not exist!"
  unset MVN_SETTINGS
fi

JAVA_VERSION=$(java -version 2>&1 | awk -F[\".] '/version/ {print ($2 == 1 ? $3 : $2)}')
echo "java version: $JAVA_VERSION"
if [ "$JAVA_VERSION" -ge 23 ]; then
  #WARNING: A terminally deprecated method in sun.misc.Unsafe has been called
  MAVEN_OPTS="$MAVEN_OPTS--enable-native-access=ALL-UNNAMED --sun-misc-unsafe-memory-access=allow"
fi

export MAVEN_OPTS="$MAVEN_OPTS -Dmaven.repo.local=$M2_ROOT/repository -Duser.home=./"

echo "Set up MAVEN_OPTS $MAVEN_OPTS"
