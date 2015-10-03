#
# release.sh
# copied from jfontmaps project and adapted

PROJECT=cjk-gs-integrate
DIR=`pwd`/..
VER=${VER:-`date +%Y%m%d.0`}

TEMP=/tmp

echo "Making Release $VER. Ctrl-C to cancel."
read REPLY
if test -d "$TEMP/$PROJECT-$VER"; then
  echo "Warning: the directory '$TEMP/$PROJECT-$VER' is found:"
  echo
  ls $TEMP/$PROJECT-$VER
  echo
  echo -n "I'm going to remove this directory. Continue? yes/No"
  echo
  read REPLY <&2
  case $REPLY in
    y*|Y*) rm -rf $TEMP/$PROJECT-$VER;;
    *) echo "Aborted."; exit 1;;
  esac
fi
echo
git commit -m "Release $VER" --allow-empty
git archive --format=tar --prefix=$PROJECT-$VER/ HEAD | (cd $TEMP && tar xf -)
git --no-pager log --date=short --format='%ad  %aN  <%ae>%n%n%x09* %s%d [%h]%n' > $TEMP/$PROJECT-$VER/ChangeLog
cd $TEMP
rm -rf $PROJECT-$VER-orig
cp -r $PROJECT-$VER $PROJECT-$VER-orig
cd $PROJECT-$VER
rm -f .gitignore
for i in cjk-gs-integrate.pl ; do
  perl -pi.bak -e "s/\\\$VER\\\$/$VER/g" $i
  rm -f ${i}.bak
done
# rename README.md to README for CTAN
mv README.md README
cd ..
diff -urN $PROJECT-$VER-orig $PROJECT-$VER
tar zcf $DIR/$PROJECT-$VER.tar.gz $PROJECT-$VER
echo
echo You should execute
echo
echo "  git push && git tag $VER && git push origin $VER"
echo
echo Informations for submitting CTAN: 
echo "  CONTRIBUTION: $PROJECT"
echo "  SUMMARY:      Tools to integrate CJK fonts into Ghostscript"
echo "  DIRECTORY:    fonts/$PROJECT"
echo "  LICENSE:      free/GPLv3"
echo "  FILE:         $DIR/$PROJECT-$VER.tar.gz"

