set(DIR ${TARGETDIR}/misc)

set(
    MODULE_IFLAGS
    ${FREERTOSDIR}/include/
    ${FREERTOSDIR}/portable/GCC/AmebaLite_KM4/non_secure
    ${FREERTOSDIR}/portable/GCC/AmebaLite_KM4/secure
)

set(CSRC ${DIR}/ameba_pmu.c)

if(CONFIG_AS_INIC_AP)
    list(
        APPEND CSRC
        ${DIR}/ameba_ota.c
    )
endif()


ameba_internal_library(target_misc)
target_include_directories(${CURRENT_LIB_NAME} PRIVATE ${MODULE_IFLAGS})
target_sources(${CURRENT_LIB_NAME} PRIVATE ${CSRC})
