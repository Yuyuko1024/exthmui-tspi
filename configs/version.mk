#
# Copyright (C) 2022 The exTHmUI Open Source Project
#
# SPDX-License-Identifier: Apache-2.0
#

# Version
EXTHM_NUM_VERSION := 11.0
EXTHM_BRANCH := Renko
EXTHM_BUILD_TYPE := DEBUG
EXTHM_DATE := $(shell date -u +%Y%m%d)
EXTHM_DEVICE := $(shell echo "$(TARGET_PRODUCT)" | cut -d '_' -f 2,3)

ifeq ($(IS_RELEASE), true)
    EXTHM_BUILD_TYPE := RELEASE
endif

EXTHM_VERSION := exTHmUI-$(EXTHM_NUM_VERSION)-$(EXTHM_BRANCH)-$(EXTHM_DEVICE)-$(EXTHM_BUILD_TYPE)-$(EXTHM_DATE)

PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    ro.exthm.version=$(EXTHM_VERSION) \
    ro.exthm.branch=$(EXTHM_BRANCH) \
    ro.exthm.build.version=$(EXTHM_NUM_VERSION) \
    ro.exthm.build.type=$(EXTHM_BUILD_TYPE)