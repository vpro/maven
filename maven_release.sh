
JOB_ENV=${JOB_ENV:=job.release.env}
export MAVEN_ARGS=${MAVEN_ARGS:=--no-transfer-progress}

mvn -ntp -U \
    -DpushChanges=false \
    --batch-mode \
    -Darguments="-DskipTests"  \
    release:clean \
    release:prepare \
    -DdryRun=$DRY_RUN
if [[ "$DRY_RUN" == "false" ]] ; then git push --atomic -v --follow-tags;  fi
git checkout $(awk -F= '$1 == "scm.tag" {print $2}' release.properties)
RELEASE_VERSION=$(mvn help:evaluate -Dexpression=project.version -q -DforceStdout)
epxort RELEASE_VERSION
export NEW_TAG="REL-$RELEASE_VERSION"
NEW_TAG_SLUG=$(echo $NEW_TAG | iconv -t ascii//TRANSLIT | sed -E -e 's/[^[:alnum:]]+/-/g' -e 's/^-+|-+$//g' | tr '[:upper:]' '[:lower:]')
export NEW_TAG_SLUG
git checkout "$CI_COMMIT_REF_NAME"
mvn -DdryRun=$DRY_RUN -Darguments="$MAVEN_ARGS -DskipTests" $MAVEN_ARGS $MAVEN_RELEASE_PROFILES  -B release:perform
echo "RELEASE_VERSION="$RELEASE_VERSION | tee -a  ${JOB_ENV}  # RELEASE_VERSION is the version that will be used in deploy stage
echo "PROJECT_VERSION="$RELEASE_VERSION | tee -a  ${JOB_ENV}  # PROJECT_VERSION recognized by kaniko image?
echo "NEW_TAG="$NEW_TAG| tee -a  $P{JOB_ENV}  # RELEASE_VERSION is the version that will be used in deploy stage
echo "NEW_TAG_SLUG="$NEW_TAG_SLUG| tee -a  ${JOB_ENV} # RELEASE_VERSION is the version that will be used in deploy stage
echo "New tag $NEW_TAG ($NEW_TAG_SLUG) created"