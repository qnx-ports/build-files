#
# Copyright  2017, QNX Software Systems Ltd.  All Rights Reserved
#
# This source code has been published by QNX Software Systems Ltd.
# (QSSL).  However, any use, reproduction, modification, distribution
# or transfer of this software, or any software which includes or is
# based upon any of this code, is only permitted under the terms of
# the QNX Open Community License version 1.0 (see licensing.qnx.com for
# details) or as otherwise expressly authorized by a written license
# agreement from QSSL.  For more information, please email licensing@qnx.com.
#
ifndef QCONFIG
QCONFIG=qconfig.mk
endif
include $(QCONFIG)

define PINFO
PINFO DESCRIPTION=SuiteSparse library
endef

INSTALLDIR=usr/lib

QNX_PROJECT_ROOT?=../../../suitesparse

BUILD=suitesparse

ifeq ($(BUILD),suitesparse)
EXTRA_SRCVPATH += $(QNX_PROJECT_ROOT)/SuiteSparse_config
EXTRA_SRCVPATH += $(QNX_PROJECT_ROOT)/BTF/Source
EXTRA_SRCVPATH += $(QNX_PROJECT_ROOT)/CCOLAMD/Source
EXTRA_SRCVPATH += $(QNX_PROJECT_ROOT)/COLAMD/Source
EXTRA_SRCVPATH += $(QNX_PROJECT_ROOT)/KLU/Source
EXTRA_SRCVPATH += $(QNX_PROJECT_ROOT)/LDL/Source
EXTRA_SRCVPATH += $(QNX_PROJECT_ROOT)/UMFPACK/Source
EXTRA_SRCVPATH += $(QNX_PROJECT_ROOT)/CHOLMOD/Core
EXTRA_SRCVPATH += $(QNX_PROJECT_ROOT)/CHOLMOD/Check
EXTRA_SRCVPATH += $(QNX_PROJECT_ROOT)/CHOLMOD/Modify
EXTRA_SRCVPATH += $(QNX_PROJECT_ROOT)/CHOLMOD/Supernodal
EXTRA_SRCVPATH += $(QNX_PROJECT_ROOT)/CHOLMOD/Cholesky
EXTRA_SRCVPATH += $(QNX_PROJECT_ROOT)/CHOLMOD/Partition
EXTRA_SRCVPATH += $(QNX_PROJECT_ROOT)/CHOLMOD/MatrixOps
EXTRA_SRCVPATH += $(QNX_PROJECT_ROOT)/SPQR/Source

EXTRA_INCVPATH += $(QNX_PROJECT_ROOT)/SuiteSparse_config
EXTRA_INCVPATH += $(QNX_PROJECT_ROOT)/AMD/Include
EXTRA_INCVPATH += $(QNX_PROJECT_ROOT)/BTF/Include
EXTRA_INCVPATH += $(QNX_PROJECT_ROOT)/CAMD/Include
EXTRA_INCVPATH += $(QNX_PROJECT_ROOT)/CCOLAMD/Include
EXTRA_INCVPATH += $(QNX_PROJECT_ROOT)/COLAMD/Include
EXTRA_INCVPATH += $(QNX_PROJECT_ROOT)/CHOLMOD/Include
EXTRA_INCVPATH += $(QNX_PROJECT_ROOT)/CXSparse/Include
EXTRA_INCVPATH += $(QNX_PROJECT_ROOT)/KLU/Include
EXTRA_INCVPATH += $(QNX_PROJECT_ROOT)/LDL/Include
EXTRA_INCVPATH += $(QNX_PROJECT_ROOT)/UMFPACK/Include
EXTRA_INCVPATH += $(QNX_PROJECT_ROOT)/SPQR/Include
EXTRA_SRCVPATH += $(QNX_PROJECT_ROOT)/SuiteSparse_config

EXTRA_INCVPATH += $(QNX_PROJECT_ROOT)/SuiteSparse_config
EXTRA_INCVPATH += $(QNX_PROJECT_ROOT)/CXSparse/Include
else
$(error "Unrecognized build: $(BUILD)")
endif

include $(MKFILES_ROOT)/qmacros.mk

EXCLUDE_OBJS += t_cholmod_change_factor.o
EXCLUDE_OBJS += t_cholmod_dense.o
EXCLUDE_OBJS += t_cholmod_transpose.o
EXCLUDE_OBJS += t_cholmod_triplet.o
EXCLUDE_OBJS += t_cholmod_gpu.o
EXCLUDE_OBJS += t_cholmod_updown_numkr.o
EXCLUDE_OBJS += t_cholmod_updown.o
EXCLUDE_OBJS += t_cholmod_sdmult.o
EXCLUDE_OBJS += t_cholmod_super_numeric.o
EXCLUDE_OBJS += t_cholmod_super_solve.o
EXCLUDE_OBJS += t_cholmod_rowfac.o
EXCLUDE_OBJS += t_cholmod_solve.o
EXCLUDE_OBJS += t_cholmod_lsolve.o
EXCLUDE_OBJS += t_cholmod_ltsolve.o

LCORE = cholmod_l_aat.o cholmod_l_add.o cholmod_l_band.o \
cholmod_l_change_factor.o cholmod_l_common.o cholmod_l_complex.o \
cholmod_l_copy.o cholmod_l_dense.o cholmod_l_error.o \
cholmod_l_factor.o cholmod_l_memory.o \
cholmod_l_sparse.o cholmod_l_transpose.o cholmod_l_triplet.o \
cholmod_l_version.o

LCHECK = cholmod_l_check.o cholmod_l_read.o cholmod_l_write.o

LCHOLESKY = cholmod_l_amd.o cholmod_l_analyze.o cholmod_l_colamd.o \
cholmod_l_etree.o cholmod_l_factorize.o cholmod_l_postorder.o \
cholmod_l_rcond.o cholmod_l_resymbol.o cholmod_l_rowcolcounts.o \
cholmod_l_rowfac.o cholmod_l_solve.o cholmod_l_spsolve.o

LMATRIXOPS = cholmod_l_drop.o cholmod_l_horzcat.o cholmod_l_norm.o \
cholmod_l_scale.o cholmod_l_sdmult.o cholmod_l_ssmult.o \
cholmod_l_submatrix.o cholmod_l_vertcat.o cholmod_l_symmetry.o

LPARTITION = cholmod_l_ccolamd.o cholmod_l_csymamd.o \
cholmod_l_metis.o cholmod_l_nesdis.o cholmod_l_camd.o

LMODIFY = cholmod_l_rowadd.o cholmod_l_rowdel.o cholmod_l_updown.o

LSUPERNODAL = cholmod_l_super_numeric.o cholmod_l_super_solve.o \
cholmod_l_super_symbolic.o

CS_DI_OBJ =  cs_add_di.o cs_amd_di.o cs_chol_di.o cs_cholsol_di.o cs_counts_di.o \
	cs_cumsum_di.o cs_droptol_di.o cs_dropzeros_di.o cs_dupl_di.o \
	cs_entry_di.o cs_etree_di.o cs_fkeep_di.o cs_gaxpy_di.o cs_happly_di.o \
	cs_house_di.o cs_ipvec_di.o cs_lsolve_di.o cs_ltsolve_di.o cs_lu_di.o \
	cs_lusol_di.o cs_util_di.o cs_multiply_di.o cs_permute_di.o cs_pinv_di.o \
	cs_post_di.o cs_pvec_di.o cs_qr_di.o cs_qrsol_di.o cs_scatter_di.o \
	cs_schol_di.o cs_sqr_di.o cs_symperm_di.o cs_tdfs_di.o cs_malloc_di.o \
	cs_transpose_di.o cs_compress_di.o cs_usolve_di.o cs_utsolve_di.o \
	cs_scc_di.o cs_maxtrans_di.o cs_dmperm_di.o cs_updown_di.o cs_print_di.o \
	cs_norm_di.o cs_load_di.o cs_dfs_di.o cs_reach_di.o cs_spsolve_di.o \
	cs_leaf_di.o cs_ereach_di.o cs_randperm_di.o

CS_DL_OBJ =  cs_add_dl.o cs_amd_dl.o cs_chol_dl.o cs_cholsol_dl.o cs_counts_dl.o \
	cs_cumsum_dl.o cs_droptol_dl.o cs_dropzeros_dl.o cs_dupl_dl.o \
	cs_entry_dl.o cs_etree_dl.o cs_fkeep_dl.o cs_gaxpy_dl.o cs_happly_dl.o \
	cs_house_dl.o cs_ipvec_dl.o cs_lsolve_dl.o cs_ltsolve_dl.o cs_lu_dl.o \
	cs_lusol_dl.o cs_util_dl.o cs_multiply_dl.o cs_permute_dl.o cs_pinv_dl.o \
	cs_post_dl.o cs_pvec_dl.o cs_qr_dl.o cs_qrsol_dl.o cs_scatter_dl.o \
	cs_schol_dl.o cs_sqr_dl.o cs_symperm_dl.o cs_tdfs_dl.o cs_malloc_dl.o \
	cs_transpose_dl.o cs_compress_dl.o cs_usolve_dl.o cs_utsolve_dl.o \
	cs_scc_dl.o cs_maxtrans_dl.o cs_dmperm_dl.o cs_updown_dl.o cs_print_dl.o \
	cs_norm_dl.o cs_load_dl.o cs_dfs_dl.o cs_reach_dl.o cs_spsolve_dl.o \
	cs_leaf_dl.o cs_ereach_dl.o cs_randperm_dl.o

CS_CI_OBJ =  cs_add_ci.o cs_amd_ci.o cs_chol_ci.o cs_cholsol_ci.o cs_counts_ci.o \
	cs_cumsum_ci.o cs_droptol_ci.o cs_dropzeros_ci.o cs_dupl_ci.o \
	cs_entry_ci.o cs_etree_ci.o cs_fkeep_ci.o cs_gaxpy_ci.o cs_happly_ci.o \
	cs_house_ci.o cs_ipvec_ci.o cs_lsolve_ci.o cs_ltsolve_ci.o cs_lu_ci.o \
	cs_lusol_ci.o cs_util_ci.o cs_multiply_ci.o cs_permute_ci.o cs_pinv_ci.o \
	cs_post_ci.o cs_pvec_ci.o cs_qr_ci.o cs_qrsol_ci.o cs_scatter_ci.o \
	cs_schol_ci.o cs_sqr_ci.o cs_symperm_ci.o cs_tdfs_ci.o cs_malloc_ci.o \
	cs_transpose_ci.o cs_compress_ci.o cs_usolve_ci.o cs_utsolve_ci.o \
	cs_scc_ci.o cs_maxtrans_ci.o cs_dmperm_ci.o cs_updown_ci.o cs_print_ci.o \
	cs_norm_ci.o cs_load_ci.o cs_dfs_ci.o cs_reach_ci.o cs_spsolve_ci.o \
	cs_leaf_ci.o cs_ereach_ci.o cs_randperm_ci.o

CS_CL_OBJ =  cs_add_cl.o cs_amd_cl.o cs_chol_cl.o cs_cholsol_cl.o cs_counts_cl.o \
	cs_cumsum_cl.o cs_droptol_cl.o cs_dropzeros_cl.o cs_dupl_cl.o \
	cs_entry_cl.o cs_etree_cl.o cs_fkeep_cl.o cs_gaxpy_cl.o cs_happly_cl.o \
	cs_house_cl.o cs_ipvec_cl.o cs_lsolve_cl.o cs_ltsolve_cl.o cs_lu_cl.o \
	cs_lusol_cl.o cs_util_cl.o cs_multiply_cl.o cs_permute_cl.o cs_pinv_cl.o \
	cs_post_cl.o cs_pvec_cl.o cs_qr_cl.o cs_qrsol_cl.o cs_scatter_cl.o \
	cs_schol_cl.o cs_sqr_cl.o cs_symperm_cl.o cs_tdfs_cl.o cs_malloc_cl.o \
	cs_transpose_cl.o cs_compress_cl.o cs_usolve_cl.o cs_utsolve_cl.o \
	cs_scc_cl.o cs_maxtrans_cl.o cs_dmperm_cl.o cs_updown_cl.o cs_print_cl.o \
	cs_norm_cl.o cs_load_cl.o cs_dfs_cl.o cs_reach_cl.o cs_spsolve_cl.o \
	cs_leaf_cl.o cs_ereach_cl.o cs_randperm_cl.o

AMD_OBJ = amd_i_aat.o amd_i_1.o amd_i_2.o amd_i_dump.o \
        amd_i_postorder.o amd_i_post_tree.o amd_i_defaults.o amd_i_order.o \
        amd_i_control.o amd_i_info.o amd_i_valid.o amd_l_aat.o amd_l_1.o \
        amd_l_2.o amd_l_dump.o amd_l_postorder.o amd_l_post_tree.o \
        amd_l_defaults.o amd_l_order.o amd_l_control.o amd_l_info.o \
        amd_l_valid.o amd_i_preprocess.o amd_l_preprocess.o

CAMD_OBJ = camd_i_aat.o camd_i_1.o camd_i_2.o camd_i_dump.o \
	    camd_i_postorder.o camd_i_defaults.o camd_i_order.o \
	    camd_i_control.o camd_i_info.o camd_i_valid.o camd_l_aat.o \
	    camd_l_1.o camd_l_2.o camd_l_dump.o camd_l_postorder.o \
	    camd_l_defaults.o camd_l_order.o camd_l_control.o camd_l_info.o \
	    camd_l_valid.o camd_i_preprocess.o camd_l_preprocess.o

PUBLIC_INCVPATH = $(EXTRA_INCVPATH)
INSTALL_ROOT_HDR := $(INSTALL_ROOT_HDR)/suitesparse

suitesparse_OBJS += $(LCORE) $(LCHECK) $(LCHOLESKY) $(LMATRIXOPS) $(LPARTITION) $(LMODIFY) $(LSUPERNODAL)
suitesparse_OBJS += $(CS_DI_OBJ) $(CS_DL_OBJ) $(CS_CI_OBJ) $(CS_CL_OBJ)
suitesparse_OBJS += $(AMD_OBJ) $(CAMD_OBJ)
suitesparse_OBJS += colamd_l.o ccolamd_l.o
suitesparse_LIBS += openblas lapack blas metis

cxsparse_OBJS += $(CS_DI_OBJ) $(CS_DL_OBJ) $(CS_CI_OBJ) $(CS_CL_OBJ)
cxsparse_LIBS +=

OBJS+=$($(BUILD)_OBJS)
LIBS+=$($(BUILD)_LIBS)

NAME=$(BUILD)

#QNX internal start
ifeq ($(filter g, $(VARIANT_LIST)),g)
DEBUG_SUFFIX=_g
LIB_SUFFIX=_g
else
DEBUG_SUFFIX=$(filter-out $(VARIANT_BUILD_TYPE) le be,$(VARIANT_LIST))
ifeq ($(DEBUG_SUFFIX),)
DEBUG_SUFFIX=_r
else
DEBUG_SUFFIX:=_$(DEBUG_SUFFIX)
endif
endif

CCFLAGS += -DBLAS_F2C -DNGPL
CXXFLAGS += -DBLAS_F2C -DNGPL

include $(MKFILES_ROOT)/qtargets.mk

COMPILE_c_o += -I$(QNX_TARGET)/include


%_di.o : CXSparse/Source/%.c
	$(COMPILE_c_o) -o $@

%_dl.o : CXSparse/Source/%.c
	$(COMPILE_c_o) -DCS_LONG -o $@

%_ci.o : CXSparse/Source/%.c
	$(COMPILE_c_o) -DCS_COMPLEX -o $@

%_cl.o : CXSparse/Source/%.c
	$(COMPILE_c_o) -DCS_LONG -DCS_COMPLEX -o $@

cholmod_l_check.o: $(QNX_PROJECT_ROOT)/CHOLMOD/Check/cholmod_check.c
	$(COMPILE_c_o) -DDLONG -o $@

cholmod_l_read.o: $(QNX_PROJECT_ROOT)/CHOLMOD/Check/cholmod_read.c
	$(COMPILE_c_o) -DDLONG -o $@

cholmod_l_write.o: $(QNX_PROJECT_ROOT)/CHOLMOD/Check/cholmod_write.c
	$(COMPILE_c_o) -DDLONG -o $@

cholmod_l_common.o: $(QNX_PROJECT_ROOT)/CHOLMOD/Core/cholmod_common.c
	$(COMPILE_c_o) -DDLONG -o $@

cholmod_l_dense.o: $(QNX_PROJECT_ROOT)/CHOLMOD/Core/cholmod_dense.c $(QNX_PROJECT_ROOT)/CHOLMOD/Core/t_cholmod_dense.c
	$(COMPILE_c_o) -DDLONG -o $@

cholmod_l_factor.o: $(QNX_PROJECT_ROOT)/CHOLMOD/Core/cholmod_factor.c
	$(COMPILE_c_o) -DDLONG -o $@

cholmod_l_change_factor.o: $(QNX_PROJECT_ROOT)/CHOLMOD/Core/cholmod_change_factor.c \
	$(QNX_PROJECT_ROOT)/CHOLMOD/Core/t_cholmod_change_factor.c
	$(COMPILE_c_o) -DDLONG -o $@

cholmod_l_memory.o: $(QNX_PROJECT_ROOT)/CHOLMOD/Core/cholmod_memory.c
	$(COMPILE_c_o) -DDLONG -o $@

cholmod_l_sparse.o: $(QNX_PROJECT_ROOT)/CHOLMOD/Core/cholmod_sparse.c
	$(COMPILE_c_o) -DDLONG -o $@

cholmod_l_complex.o: $(QNX_PROJECT_ROOT)/CHOLMOD/Core/cholmod_complex.c
	$(COMPILE_c_o) -DDLONG -o $@

cholmod_l_transpose.o: $(QNX_PROJECT_ROOT)/CHOLMOD/Core/cholmod_transpose.c $(QNX_PROJECT_ROOT)/CHOLMOD/Core/t_cholmod_transpose.c
	$(COMPILE_c_o) -DDLONG -o $@

cholmod_l_band.o: $(QNX_PROJECT_ROOT)/CHOLMOD/Core/cholmod_band.c
	$(COMPILE_c_o) -DDLONG -o $@

cholmod_l_copy.o: $(QNX_PROJECT_ROOT)/CHOLMOD/Core/cholmod_copy.c
	$(COMPILE_c_o) -DDLONG -o $@

cholmod_l_triplet.o: $(QNX_PROJECT_ROOT)/CHOLMOD/Core/cholmod_triplet.c $(QNX_PROJECT_ROOT)/CHOLMOD/Core/t_cholmod_triplet.c
	$(COMPILE_c_o) -DDLONG -o $@

cholmod_l_error.o: $(QNX_PROJECT_ROOT)/CHOLMOD/Core/cholmod_error.c
	$(COMPILE_c_o) -DDLONG -o $@

cholmod_l_aat.o: $(QNX_PROJECT_ROOT)/CHOLMOD/Core/cholmod_aat.c
	$(COMPILE_c_o) -DDLONG -o $@

cholmod_l_add.o: $(QNX_PROJECT_ROOT)/CHOLMOD/Core/cholmod_add.c
	$(COMPILE_c_o) -DDLONG -o $@

cholmod_l_version.o: $(QNX_PROJECT_ROOT)/CHOLMOD/Core/cholmod_version.c
	$(COMPILE_c_o) -DDLONG -o $@

cholmod_l_amd.o: $(QNX_PROJECT_ROOT)/CHOLMOD/Cholesky/cholmod_amd.c
	$(COMPILE_c_o) -DDLONG -o $@

cholmod_l_analyze.o: $(QNX_PROJECT_ROOT)/CHOLMOD/Cholesky/cholmod_analyze.c
	$(COMPILE_c_o) -DDLONG -o $@

cholmod_l_colamd.o: $(QNX_PROJECT_ROOT)/CHOLMOD/Cholesky/cholmod_colamd.c
	$(COMPILE_c_o) -DDLONG -o $@

cholmod_l_etree.o: $(QNX_PROJECT_ROOT)/CHOLMOD/Cholesky/cholmod_etree.c
	$(COMPILE_c_o) -DDLONG -o $@

cholmod_l_factorize.o: $(QNX_PROJECT_ROOT)/CHOLMOD/Cholesky/cholmod_factorize.c
	$(COMPILE_c_o) -DDLONG -o $@

cholmod_l_postorder.o: $(QNX_PROJECT_ROOT)/CHOLMOD/Cholesky/cholmod_postorder.c
	$(COMPILE_c_o) -DDLONG -o $@

cholmod_l_rcond.o: $(QNX_PROJECT_ROOT)/CHOLMOD/Cholesky/cholmod_rcond.c
	$(COMPILE_c_o) -DDLONG -o $@

cholmod_l_resymbol.o: $(QNX_PROJECT_ROOT)/CHOLMOD/Cholesky/cholmod_resymbol.c
	$(COMPILE_c_o) -DDLONG -o $@

cholmod_l_rowcolcounts.o: $(QNX_PROJECT_ROOT)/CHOLMOD/Cholesky/cholmod_rowcolcounts.c
	$(COMPILE_c_o) -DDLONG -o $@

cholmod_l_solve.o: $(QNX_PROJECT_ROOT)/CHOLMOD/Cholesky/cholmod_solve.c $(QNX_PROJECT_ROOT)/CHOLMOD/Cholesky/t_cholmod_lsolve.c \
	$(QNX_PROJECT_ROOT)/CHOLMOD/Cholesky/t_cholmod_ltsolve.c $(QNX_PROJECT_ROOT)/CHOLMOD/Cholesky/t_cholmod_solve.c
	$(COMPILE_c_o) -DDLONG -o $@

cholmod_l_spsolve.o: $(QNX_PROJECT_ROOT)/CHOLMOD/Cholesky/cholmod_spsolve.c
	$(COMPILE_c_o) -DDLONG -o $@

cholmod_l_rowfac.o: $(QNX_PROJECT_ROOT)/CHOLMOD/Cholesky/cholmod_rowfac.c $(QNX_PROJECT_ROOT)/CHOLMOD/Cholesky/t_cholmod_rowfac.c
	$(COMPILE_c_o) -DDLONG -o $@

cholmod_l_ccolamd.o: $(QNX_PROJECT_ROOT)/CHOLMOD/Partition/cholmod_ccolamd.c
	$(COMPILE_c_o) -DDLONG -o $@

cholmod_l_csymamd.o: $(QNX_PROJECT_ROOT)/CHOLMOD/Partition/cholmod_csymamd.c
	$(COMPILE_c_o) -DDLONG -o $@

cholmod_l_camd.o: $(QNX_PROJECT_ROOT)/CHOLMOD/Partition/cholmod_camd.c
	$(COMPILE_c_o) -DDLONG -o $@

cholmod_l_metis.o: $(QNX_PROJECT_ROOT)/CHOLMOD/Partition/cholmod_metis.c
	$(COMPILE_c_o) -DDLONG -o $@

cholmod_l_nesdis.o: $(QNX_PROJECT_ROOT)/CHOLMOD/Partition/cholmod_nesdis.c
	$(COMPILE_c_o) -DDLONG -o $@

cholmod_l_horzcat.o: $(QNX_PROJECT_ROOT)/CHOLMOD/MatrixOps/cholmod_horzcat.c
	$(COMPILE_c_o) -DDLONG -o $@

cholmod_l_norm.o: $(QNX_PROJECT_ROOT)/CHOLMOD/MatrixOps/cholmod_norm.c
	$(COMPILE_c_o) -DDLONG -o $@

cholmod_l_scale.o: $(QNX_PROJECT_ROOT)/CHOLMOD/MatrixOps/cholmod_scale.c
	$(COMPILE_c_o) -DDLONG -o $@

cholmod_l_drop.o: $(QNX_PROJECT_ROOT)/CHOLMOD/MatrixOps/cholmod_drop.c
	$(COMPILE_c_o) -DDLONG -o $@

cholmod_l_sdmult.o: $(QNX_PROJECT_ROOT)/CHOLMOD/MatrixOps/cholmod_sdmult.c \
	$(QNX_PROJECT_ROOT)/CHOLMOD/MatrixOps/t_cholmod_sdmult.c
	$(COMPILE_c_o) -DDLONG -o $@

cholmod_l_ssmult.o: $(QNX_PROJECT_ROOT)/CHOLMOD/MatrixOps/cholmod_ssmult.c
	$(COMPILE_c_o) -DDLONG -o $@

cholmod_l_submatrix.o: $(QNX_PROJECT_ROOT)/CHOLMOD/MatrixOps/cholmod_submatrix.c
	$(COMPILE_c_o) -DDLONG -o $@

cholmod_l_vertcat.o: $(QNX_PROJECT_ROOT)/CHOLMOD/MatrixOps/cholmod_vertcat.c
	$(COMPILE_c_o) -DDLONG -o $@

cholmod_l_symmetry.o: $(QNX_PROJECT_ROOT)/CHOLMOD/MatrixOps/cholmod_symmetry.c
	$(COMPILE_c_o) -DDLONG -o $@

cholmod_l_rowadd.o: $(QNX_PROJECT_ROOT)/CHOLMOD/Modify/cholmod_rowadd.c
	$(COMPILE_c_o) -DDLONG -o $@

cholmod_l_rowdel.o: $(QNX_PROJECT_ROOT)/CHOLMOD/Modify/cholmod_rowdel.c
	$(COMPILE_c_o) -DDLONG -o $@

cholmod_l_updown.o: $(QNX_PROJECT_ROOT)/CHOLMOD/Modify/cholmod_updown.c \
	$(QNX_PROJECT_ROOT)/CHOLMOD/Modify/t_cholmod_updown.c $(QNX_PROJECT_ROOT)/CHOLMOD/Modify/t_cholmod_updown_numkr.c
	$(COMPILE_c_o) -DDLONG -o $@

cholmod_l_super_numeric.o: $(QNX_PROJECT_ROOT)/CHOLMOD/Supernodal/cholmod_super_numeric.c \
	$(QNX_PROJECT_ROOT)/CHOLMOD/Supernodal/t_cholmod_super_numeric.c
	$(COMPILE_c_o) -DDLONG -o $@

cholmod_l_super_symbolic.o: $(QNX_PROJECT_ROOT)/CHOLMOD/Supernodal/cholmod_super_symbolic.c
	$(COMPILE_c_o) -DDLONG -o $@

cholmod_l_super_solve.o: $(QNX_PROJECT_ROOT)/CHOLMOD/Supernodal/cholmod_super_solve.c \
	$(QNX_PROJECT_ROOT)/CHOLMOD/Supernodal/t_cholmod_super_solve.c
	$(COMPILE_c_o) -DDLONG -o $@

colamd_l.o: $(QNX_PROJECT_ROOT)/COLAMD/Source/colamd.c
	$(COMPILE_c_o) -DDLONG -o $@

ccolamd_l.o: $(QNX_PROJECT_ROOT)/CCOLAMD/Source/ccolamd.c
	$(COMPILE_c_o) -DDLONG -o $@

amd_i_%.o: $(QNX_PROJECT_ROOT)/AMD/Source/amd_%.c
	$(COMPILE_c_o) -DDINT -o $@

amd_l_%.o: $(QNX_PROJECT_ROOT)/AMD/Source/amd_%.c
	$(COMPILE_c_o) -DDLONG -o $@

camd_i_%.o: $(QNX_PROJECT_ROOT)/CAMD/Source/camd_%.c
	$(COMPILE_c_o) -DDINT -o $@

camd_l_%.o: $(QNX_PROJECT_ROOT)/CAMD/Source/camd_%.c
	$(COMPILE_c_o) -DDLONG -o $@

