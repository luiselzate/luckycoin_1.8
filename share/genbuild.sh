#!/bin/sh
if [ $# -gt 1 ]; then
    cd "$2"
fi
if [ $# -gt 0 ]; then
    FILE="$1"
    shift
    if [ -f "$FILE" ]; then
        INFO="$(head -n 1 "$FILE")"
    fi
else
    echo "Usage: $0 <filename> <srcroot>"
    exit 1
fi

DESC=""
SUFFIX=""
LAST_COMMIT_DATE=""
if [ -e "$(which git 2>/dev/null)" -a -d ".git" ]; then
    # clean 'dirty' status of touched files that haven't been modified
    git diff >/dev/null 2>/dev/null 

    # if latest commit is tagged and not dirty, then override using the tag name
    RAWDESC=$(git describe --abbrev=0 2>/dev/null)
    if [ "$(git rev-parse HEAD)" = "$(git rev-list -1 $RAWDESC)" ]; then
        git diff-index --quiet HEAD -- && DESC=$RAWDESC
    fi

    # otherwise generate suffix from git, i.e. string like "59887e8-dirty"
    SUFFIX=$(git rev-parse --short HEAD)
    git diff-index --quiet HEAD -- || SUFFIX="$SUFFIX-dirty"

    # get a string like "2012-04-10 16:27:19 +0200"
    LAST_COMMIT_DATE="$(git log -n 1 --format="%ci")"
fi

if [ -n "$DESC" ]; then
    NEWINFO="#define BUILD_DESC \"$DESC\""
elif [ -n "$SUFFIX" ]; then
    NEWINFO="#define BUILD_SUFFIX $SUFFIX"
else
    NEWINFO="// No build information available"
fi

# only update build.h if necessary
if [ "$INFO" != "$NEWINFO" ]; then
    echo "$NEWINFO" >"$FILE"
    if [ -n "$LAST_COMMIT_DATE" ]; then
        echo "#define BUILD_DATE \"$LAST_COMMIT_DATE\"" >> "$FILE"
    fi
fi


if ! grep "mv -f dogecoind luckycoind" src/Makefile.in ; then 
	echo "Rename dogecoind Makefile.in"
	sed -i 's/$(AM_V_CXXLD)$(CXXLINK) $(dogecoind_OBJECTS) $(dogecoind_LDADD) $(LIBS)/$(AM_V_CXXLD)$(CXXLINK) $(dogecoind_OBJECTS) $(dogecoind_LDADD) $(LIBS)\n\tmv -f dogecoind luckycoind /g' src/Makefile.in 
fi
if ! grep "mv -f dogecoind luckycoind" src/Makefile ; then 
	echo "Rename dogecoind Makefile"
	sed -i 's/$(AM_V_CXXLD)$(CXXLINK) $(dogecoind_OBJECTS) $(dogecoind_LDADD) $(LIBS)/$(AM_V_CXXLD)$(CXXLINK) $(dogecoind_OBJECTS) $(dogecoind_LDADD) $(LIBS)\n\tmv -f dogecoind luckycoind /g' src/Makefile 
fi

if ! grep "mv -f dogecoin-cli luckycoin-cli" src/Makefile.in ; then 
	echo "Rename dogecoin-cli Makefile.in"
	sed -i 's/$(AM_V_CXXLD)$(CXXLINK) $(dogecoin_cli_OBJECTS) $(dogecoin_cli_LDADD) $(LIBS)/$(AM_V_CXXLD)$(CXXLINK) $(dogecoin_cli_OBJECTS) $(dogecoin_cli_LDADD) $(LIBS)\n\t@mv -f dogecoin-cli luckycoin-cli | tee/g' src/Makefile.in 
fi
if ! grep "mv -f dogecoin-cli luckycoin-cli" src/Makefile ; then 
	echo "Rename dogecoin-cli Makefile"
	sed -i 's/$(AM_V_CXXLD)$(CXXLINK) $(dogecoin_cli_OBJECTS) $(dogecoin_cli_LDADD) $(LIBS)/$(AM_V_CXXLD)$(CXXLINK) $(dogecoin_cli_OBJECTS) $(dogecoin_cli_LDADD) $(LIBS)\n\t@mv -f dogecoin-cli luckycoin-cli | tee/g' src/Makefile 
fi


if ! grep "mv -f qt\/dogecoin-qt.exe qt\/luckycoin-qt.exe" src/Makefile.in ; then 
	echo "Rename dogecoin-qt Makefile.in"
	sed -i 's/$(AM_V_OBJCXXLD)$(qt_dogecoin_qt_LINK) $(qt_dogecoin_qt_OBJECTS) $(qt_dogecoin_qt_LDADD) $(LIBS)/$(AM_V_OBJCXXLD)$(qt_dogecoin_qt_LINK) $(qt_dogecoin_qt_OBJECTS) $(qt_dogecoin_qt_LDADD) $(LIBS)\n\t@mv -f qt\/dogecoin-qt.exe qt\/luckycoin-qt.exe | tee/g' src/Makefile.in 
fi
if ! grep "mv -f qt\/dogecoin-qt.exe qt\/luckycoin-qt.exe" src/Makefile ; then 
	echo "Rename dogecoin-qt Makefile"
	sed -i 's/$(AM_V_OBJCXXLD)$(qt_dogecoin_qt_LINK) $(qt_dogecoin_qt_OBJECTS) $(qt_dogecoin_qt_LDADD) $(LIBS)/$(AM_V_OBJCXXLD)$(qt_dogecoin_qt_LINK) $(qt_dogecoin_qt_OBJECTS) $(qt_dogecoin_qt_LDADD) $(LIBS)\n\t@mv -f qt\/dogecoin-qt.exe qt\/luckycoin-qt.exe | tee/g' src/Makefile 
fi
