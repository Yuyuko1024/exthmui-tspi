#
# Copyright (C) 2022 The exTHmUI Open Source Project
#
# SPDX-License-Identifier: Apache-2.0
#

ADDITIONAL_BUILD_PROPERTIES += \
    ro.exthm.version=$(EXTHM_VERSION) \
    ro.exthm.branch=$(EXTHM_BRANCH) \
    ro.exthm.build.version=$(EXTHM_NUM_VERSION) \
    ro.exthm.build.type=$(EXTHM_BUILD_TYPE)