#### this file is intended to be included in a common.mk file to determine which
#### sdp is being used to build the package. it determines the sdp by looking
#### for specific ../target/.. folders. it will also indicate whether special io-sock
#### folders are in play
#### __QNXNTO__    so that this file will be easy to find for updates

$(info common.mk-sdp-finder.mk QNX_TARGET= $(QNX_TARGET))

## looking for ..target/qnx7 so we can determine mainline (target/qnx) or sdp7.0/sdp7.1 (target/qnx7)
ifeq ($(findstring target/qnx7,$(QNX_TARGET)),target/qnx7)

    ## looks to be a sdp7 of some kind. 7.0 or 7.1. see if we can find an io-sock folder. if we can
    ## then we're using sdp7.1. if not then we're using sdp7.0
    DIR_TO_CHECK_FOR= ${QNX_TARGET}/io-sock
#    $(info common.mk-sdp-finder.mk DIR_TO_CHECK_FOR= $(DIR_TO_CHECK_FOR) )

    ifeq ("$(wildcard $(DIR_TO_CHECK_FOR))", "")
        ## must be 7.0 because the folder doesn't exist. no io-sock in 7.0
        BUILD_SDP=sdp70
        SPECIAL_IO_SOCK_FOLDERS=no
    else
        ## must be 7.1 because the folder exists. 7.1 supports io-sock with extra folders
        BUILD_SDP=sdp71
        SPECIAL_IO_SOCK_FOLDERS=yes
    endif
else
    ifeq ($(findstring target/qnx,$(QNX_TARGET)),target/qnx)
        BUILD_SDP=mainline
        SPECIAL_IO_SOCK_FOLDERS=no
    endif
endif

$(info common.mk-sdp-finder.mk BUILD_SDP= $(BUILD_SDP))
$(info common.mk-sdp-finder.mk SPECIAL_IO_SOCK_FOLDERS= $(SPECIAL_IO_SOCK_FOLDERS))