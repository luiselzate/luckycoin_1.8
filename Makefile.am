ACLOCAL_AMFLAGS = -I src/m4
SUBDIRS = src
.PHONY: deploy

GZIP_ENV="-9n"

BITCOIND_BIN=$(top_builddir)/src/luckycoind$(EXEEXT)
BITCOIN_QT_BIN=$(top_builddir)/src/qt/luckycoin-qt$(EXEEXT)
BITCOIN_CLI_BIN=$(top_builddir)/src/luckycoin-cli$(EXEEXT)
BITCOIN_WIN_INSTALLER=$(PACKAGE)-$(PACKAGE_VERSION)-win$(WINDOWS_BITS)-setup$(EXEEXT)

OSX_APP=Dogecoin-Qt.app
OSX_DMG=Dogecoin-Qt.dmg
OSX_DEPLOY_SCRIPT=$(top_srcdir)/contrib/macdeploy/macdeployqtplus
OSX_FANCY_PLIST=$(top_srcdir)/contrib/macdeploy/fancy.plist
OSX_INSTALLER_ICONS=$(top_srcdir)/src/qt/res/icons/bitcoin.icns
OSX_PLIST=$(top_srcdir)/share/qt/Info.plist #not installed
OSX_QT_TRANSLATIONS = da,de,es,hu,ru,uk,zh_CN,zh_TW

DIST_DOCS = $(wildcard doc/*.md) $(wildcard doc/release-notes/*.md)

WINDOWS_PACKAGING = $(top_srcdir)/share/pixmaps/bitcoin.ico \
  $(top_srcdir)/share/pixmaps/nsis-header.bmp \
  $(top_srcdir)/share/pixmaps/nsis-wizard.bmp \
  $(top_srcdir)/doc/README_windows.txt

OSX_PACKAGING = $(OSX_DEPLOY_SCRIPT) $(OSX_FANCY_PLIST) $(OSX_INSTALLER_ICONS) \
  $(top_srcdir)/contrib/macdeploy/background.png \
  $(top_srcdir)/contrib/macdeploy/DS_Store

COVERAGE_INFO = baseline_filtered_combined.info baseline.info block_test.info \
  leveldb_baseline.info test_bitcoin_filtered.info total_coverage.info \
  baseline_filtered.info block_test_filtered.info \
  leveldb_baseline_filtered.info test_bitcoin_coverage.info test_bitcoin.info

dist-hook:
	-$(MAKE) -C $(top_distdir)/src/leveldb clean
	-$(GIT) archive --format=tar HEAD -- src/version.cpp | $(AMTAR) -C $(top_distdir) -xf -

distcheck-hook:
	$(MKDIR_P) $(top_distdir)/_build/src/leveldb
	cp -rf $(top_srcdir)/src/leveldb/* $(top_distdir)/_build/src/leveldb/
	-$(MAKE) -C $(top_distdir)/_build/src/leveldb clean

distcleancheck:
	@:

$(BITCOIN_WIN_INSTALLER): $(BITCOIND_BIN) $(BITCOIN_QT_BIN) $(BITCOIN_CLI_BIN)
	$(MKDIR_P) $(top_builddir)/release
	STRIPPROG="$(STRIP)" $(INSTALL_STRIP_PROGRAM) $(BITCOIND_BIN) $(top_builddir)/release
	STRIPPROG="$(STRIP)" $(INSTALL_STRIP_PROGRAM) $(BITCOIN_QT_BIN) $(top_builddir)/release
	STRIPPROG="$(STRIP)" $(INSTALL_STRIP_PROGRAM) $(BITCOIN_CLI_BIN) $(top_builddir)/release
	@test -f $(MAKENSIS) && $(MAKENSIS) $(top_builddir)/share/setup.nsi || \
	  echo error: could not build $@

$(BITCOIND_BIN) $(BITCOIN_QT_BIN) $(BITCOIN_CLI_BIN):
	make -C $(dir $@) $(notdir $@)

$(OSX_APP)/Contents/PkgInfo:
	$(MKDIR_P) $(@D)
	@echo "APPL????" > $@

$(OSX_APP)/Contents/Resources/empty.lproj:
	$(MKDIR_P) $(@D)
	@touch $@

$(OSX_APP)/Contents/Info.plist: $(OSX_PLIST)
	$(MKDIR_P) $(@D)
	$(INSTALL_DATA) $< $@

$(OSX_APP)/Contents/Resources/bitcoin.icns: $(OSX_INSTALLER_ICONS)
	$(MKDIR_P) $(@D)
	$(INSTALL_DATA) $< $@

$(OSX_APP)/Contents/MacOS/Dogecoin-Qt: $(BITCOIN_QT_BIN)
	$(MKDIR_P) $(@D)
	STRIPPROG="$(STRIP)" $(INSTALL_STRIP_PROGRAM)  $< $@

OSX_APP_BUILT=$(OSX_APP)/Contents/PkgInfo $(OSX_APP)/Contents/Resources/empty.lproj \
  $(OSX_APP)/Contents/Resources/bitcoin.icns $(OSX_APP)/Contents/Info.plist \
  $(OSX_APP)/Contents/MacOS/Dogecoin-Qt

if BUILD_DARWIN
$(OSX_DMG): $(OSX_APP_BUILT) $(OSX_PACKAGING)
	$(OSX_DEPLOY_SCRIPT) $(OSX_APP) -add-qt-tr $(OSX_QT_TRANSLATIONS) -dmg -fancy $(OSX_FANCY_PLIST) -verbose 2

else
$(OSX_DMG): $(OSX_APP_BUILT) $(OSX_PACKAGING)
	INSTALLNAMETOOL=$(INSTALLNAMETOOL)  OTOOL=$(OTOOL) STRIP=$(STRIP) $(OSX_DEPLOY_SCRIPT) $(OSX_APP) -add-qt-tr $(OSX_QT_TRANSLATIONS) -verbose 2
	$(MKDIR_P) dist/.background
	$(INSTALL) contrib/macdeploy/background.png dist/.background
	$(INSTALL) contrib/macdeploy/DS_Store dist/.DS_Store
	cd dist; $(LN_S) /Applications Applications
	$(GENISOIMAGE) -no-cache-inodes -l -probe -V "Dogecoin-Qt" -no-pad -r -apple -o $@ dist
endif

if TARGET_DARWIN
appbundle: $(OSX_APP_BUILT)
deploy: $(OSX_DMG)
endif
if TARGET_WINDOWS
deploy: $(BITCOIN_WIN_INSTALLER)
endif

if USE_LCOV

baseline.info:
	$(LCOV) -c -i -d $(abs_builddir)/src -o $@

baseline_filtered.info: baseline.info
	$(LCOV) -r $< "/usr/include/*" -o $@

leveldb_baseline.info: baseline_filtered.info
	$(LCOV) -c -i -d $(abs_builddir)/src/leveldb -b $(abs_builddir)/src/leveldb -o $@

leveldb_baseline_filtered.info: leveldb_baseline.info
	$(LCOV) -r $< "/usr/include/*" -o $@

baseline_filtered_combined.info: leveldb_baseline_filtered.info baseline_filtered.info
	$(LCOV) -a leveldb_baseline_filtered.info -a baseline_filtered.info -o $@

test_bitcoin.info: baseline_filtered_combined.info
	$(MAKE) -C src/ check
	$(LCOV) -c -d $(abs_builddir)/src -t test_dogecoin -o $@
	$(LCOV) -z -d $(abs_builddir)/src
	$(LCOV) -z -d $(abs_builddir)/src/leveldb

test_bitcoin_filtered.info: test_bitcoin.info
	$(LCOV) -r $< "/usr/include/*" -o $@

if USE_COMPARISON_TOOL
block_test.info: test_bitcoin_filtered.info
	$(MKDIR_P) qa/tmp
	-@TIMEOUT=15 qa/pull-tester/run-bitcoind-for-test.sh $(JAVA) -jar $(JAVA_COMPARISON_TOOL) qa/tmp/compTool 0
	$(LCOV) -c -d $(abs_builddir)/src --t BitcoinJBlockTest -o $@
	$(LCOV) -z -d $(abs_builddir)/src
	$(LCOV) -z -d $(abs_builddir)/src/leveldb

block_test_filtered.info: block_test.info
	$(LCOV) -r $< "/usr/include/*" -o $@
endif

test_bitcoin_coverage.info: baseline_filtered_combined.info test_bitcoin_filtered.info
	$(LCOV) -a baseline_filtered.info -a leveldb_baseline_filtered.info -a test_bitcoin_filtered.info -o $@

if USE_COMPARISON_TOOL
total_coverage.info:  baseline_filtered_combined.info test_bitcoin_filtered.info block_test_filtered.info
	$(LCOV) -a baseline_filtered.info -a leveldb_baseline_filtered.info -a test_bitcoin_filtered.info -a block_test_filtered.info -o $@ | $(GREP) "\%" | $(AWK) '{ print substr($$3,2,50) "/" $$5 }' > coverage_percent.txt
else
total_coverage.info:  baseline_filtered_combined.info test_bitcoin_filtered.info
	$(LCOV) -a baseline_filtered.info -a leveldb_baseline_filtered.info -a test_bitcoin_filtered.info -o $@ | $(GREP) "\%" | $(AWK) '{ print substr($$3,2,50) "/" $$5 }' > coverage_percent.txt
endif

test_bitcoin.coverage/.dirstamp:  test_bitcoin_coverage.info
	$(GENHTML) -s $< -o $(@D)
	@touch $@

total.coverage/.dirstamp: total_coverage.info
	$(GENHTML) -s $< -o $(@D)
	@touch $@

cov: test_bitcoin.coverage/.dirstamp total.coverage/.dirstamp

endif

if USE_COMPARISON_TOOL
check-local:
	$(MKDIR_P) qa/tmp
	@qa/pull-tester/run-bitcoind-for-test.sh $(JAVA) -jar $(JAVA_COMPARISON_TOOL) qa/tmp/compTool $(COMPARISON_TOOL_REORG_TESTS)
endif

EXTRA_DIST = $(top_srcdir)/share/genbuild.sh qa/pull-tester/pull-tester.sh qa/rpc-tests $(DIST_DOCS) $(WINDOWS_PACKAGING) $(OSX_PACKAGING)

CLEANFILES = $(OSX_DMG) $(BITCOIN_WIN_INSTALLER)

.INTERMEDIATE: $(COVERAGE_INFO)

clean-local:
	rm -rf test_bitcoin.coverage/ total.coverage/ $(OSX_APP)
