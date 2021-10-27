# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := libbacktrace
$(PKG)_WEBSITE  := https://gcc.gnu.org/
$(PKG)_DESCR    := GNU backtrace library
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := d0f5e95
$(PKG)_CHECKSUM := 8678a5e1303ecc5b020ff23149f6cfa91e11c4a50ac3725064c5694afc811173
$(PKG)_GH_CONF  := ianlancetaylor/libbacktrace/branches/master
$(PKG)_DEPS     := cc

define $(PKG)_CONFIGURE
    # Configure
	cd '$(BUILD_DIR)' && '$(SOURCE_DIR)/configure' \
        $(MXE_DISABLE_DOC_OPTS) \
		--host='$(TARGET)' \
        --target='$(TARGET)' \
        --build='$(BUILD)' \
        --prefix='$(PREFIX)/$(TARGET)' \
        --with-sysroot='$(PREFIX)/$(TARGET)' \
        --disable-multilib \
		--disable-shared \
        --enable-threads=$(MXE_GCC_THREADS) \
        --with-gcc \
        --with-gnu-ld \
        --with-gnu-as \
        --with-as='$(PREFIX)/bin/$(TARGET)-as' \
        --with-ld='$(PREFIX)/bin/$(TARGET)-ld' \
        --with-nm='$(PREFIX)/bin/$(TARGET)-nm' \
        $($(PKG)_CONFIGURE_OPTS)
endef

define $(PKG)_MAKE
    # Build using its makefile
	$(MAKE) -C '$(BUILD_DIR)' -j '$(JOBS)'
	
	# Install
    $(MAKE) -C '$(BUILD_DIR)' -j 1 install
endef

define $(PKG)_POST_MAKE
	# Create pkg-config file
    $(INSTALL) -d '$(PREFIX)/$(TARGET)/lib/pkgconfig'
    (echo 'Name: $(PKG)' \
    ;echo 'Version: 1.0.0-$($(PKG)_VERSION)' \
    ;echo 'Description: $(PKG)' \
    ;echo 'Requires: ' \
    ;echo 'Libs: -lbacktrace -lstdc++' \
    ) > '$(PREFIX)/$(TARGET)/lib/pkgconfig/libbacktrace.pc'
	
	# Make shared libraries
	$(if $(BUILD_SHARED),\
        rm -f '$(PREFIX)/$(TARGET)/lib/libbacktrace.a' && \
        $(MAKE_SHARED_FROM_STATIC) '$(BUILD_DIR)/.libs/libbacktrace.a' \
		`$(TARGET)-pkg-config libbacktrace --libs-only-l | $(SED) 's/-lbacktrace//'` \
    )
	
	# @todo . Create some tests :C
	# These tests are build-time and prepared for Unix :/
	$(MAKE) -d -C '$(BUILD_DIR)' -j '$(JOBS)' check-TESTS
endef

define $(PKG)_BUILD
    $($(PKG)_CONFIGURE)
	$($(PKG)_MAKE)
	$($(PKG)_POST_MAKE)
endef

