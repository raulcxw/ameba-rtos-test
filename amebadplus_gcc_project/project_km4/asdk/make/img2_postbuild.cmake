#Note: Previously defined variables cannot be used directly in this file
#unless passed through -D
include(${CMAKE_FILES_DIR}/axf2bin.cmake)

execute_process(
	COMMAND ${CMAKE_OBJCOPY} -j .ram_image2.entry -Obinary ${IMAGE_TARGET_FOLDER}/target_pure_img2.axf ${IMAGE_TARGET_FOLDER}/entry.bin
	COMMAND ${CMAKE_OBJCOPY} -j .sram_image2.text.data -Obinary ${IMAGE_TARGET_FOLDER}/target_pure_img2.axf ${IMAGE_TARGET_FOLDER}/sram_2.bin
)

file(READ ${IMAGE_TARGET_FOLDER}/target_img2.map content)
string(REPLACE "\n" ";" lines ${content})
foreach(_line ${lines})
    string(REGEX MATCH "^.*__exidx_end" result ${_line})
    if(result)
        break()
    endif()
endforeach()
string(REPLACE " " ";" match_line "${result}")
list(GET match_line 0 ARMExAddr)

if(0x${ARMExAddr} GREATER 0x60000000)
    execute_process(
        COMMAND ${CMAKE_OBJCOPY} -j .psram_image2.text.data -j .ARM.extab -j .ARM.exidx -Obinary ${IMAGE_TARGET_FOLDER}/target_pure_img2.axf ${IMAGE_TARGET_FOLDER}/psram_2.bin
        COMMAND ${CMAKE_OBJCOPY} -j .xip_image2.text -Obinary ${IMAGE_TARGET_FOLDER}/target_pure_img2.axf ${IMAGE_TARGET_FOLDER}/xip_image2.bin
    )
else()
    execute_process(
        COMMAND ${CMAKE_OBJCOPY} -j .psram_image2.text.data -Obinary ${IMAGE_TARGET_FOLDER}/target_pure_img2.axf ${IMAGE_TARGET_FOLDER}/psram_2.bin
        COMMAND ${CMAKE_OBJCOPY} -j .xip_image2.text -j .ARM.extab -j .ARM.exidx -Obinary ${IMAGE_TARGET_FOLDER}/target_pure_img2.axf ${IMAGE_TARGET_FOLDER}/xip_image2.bin
    )
endif()

if(CONFIG_BT)
    execute_process(
        COMMAND ${CMAKE_OBJCOPY} -j .bluetooth_trace.text -Obinary ${IMAGE_TARGET_FOLDER}/target_pure_img2.axf ${IMAGE_TARGET_FOLDER}/APP.trace
    )
endif()


message( "========== Image manipulating start ==========")

execute_process(
    COMMAND ${PADTOOL} ${IMAGE_TARGET_FOLDER}/xip_image2.bin 32
	COMMAND ${PADTOOL} ${IMAGE_TARGET_FOLDER}/sram_2.bin 32
	COMMAND ${PADTOOL} ${IMAGE_TARGET_FOLDER}/psram_2.bin 32
	COMMAND ${PADTOOL} ${IMAGE_TARGET_FOLDER}/entry.bin 32
)

if(CONFIG_MP_SHRINK)
    file(WRITE ${IMAGE_TARGET_FOLDER}/xip_image2.bin "")
    file(WRITE ${IMAGE_TARGET_FOLDER}/psram_2.bin "")
endif()

execute_process(
	COMMAND ${PREPENDTOOL} ${IMAGE_TARGET_FOLDER}/xip_image2.bin  __flash_text_start__  ${IMAGE_TARGET_FOLDER}/target_img2.map
    COMMAND ${PREPENDTOOL} ${IMAGE_TARGET_FOLDER}/sram_2.bin  __sram_image2_start__  ${IMAGE_TARGET_FOLDER}/target_img2.map
	COMMAND ${PREPENDTOOL} ${IMAGE_TARGET_FOLDER}/psram_2.bin  __psram_image2_start__  ${IMAGE_TARGET_FOLDER}/target_img2.map
	COMMAND ${PREPENDTOOL} ${IMAGE_TARGET_FOLDER}/entry.bin  __image2_entry_func__  ${IMAGE_TARGET_FOLDER}/target_img2.map
)

execute_process(
    COMMAND ${CMAKE_COMMAND} -E cat ${IMAGE_TARGET_FOLDER}/xip_image2_prepend.bin ${IMAGE_TARGET_FOLDER}/sram_2_prepend.bin ${IMAGE_TARGET_FOLDER}/psram_2_prepend.bin ${IMAGE_TARGET_FOLDER}/entry_prepend.bin
    OUTPUT_FILE ${IMAGE_TARGET_FOLDER}/km4_image2_all.bin
)
execute_process(
    COMMAND ${IMAGETOOL} ${IMAGE_TARGET_FOLDER}/km4_image2_all.bin ${BUILD_TYPE}
    WORKING_DIRECTORY ${PROJECTDIR}/..
)

if(CONFIG_FATFS_WITHIN_APP_IMG)
    if(EXISTS ${IMAGE_TARGET_FOLDER}/km0_km4_app.bin AND EXISTS ${BASEDIR}/amebadplus_gcc_project/fatfs.bin)
        execute_process(
            COMMAND ${CMAKE_COMMAND} -E rename ${IMAGE_TARGET_FOLDER}/km0_km4_app.bin ${IMAGE_TARGET_FOLDER}/km0_km4_app_tmp.bin
        )
        execute_process(
            COMMAND ${CMAKE_COMMAND} -E rename ${IMAGE_TARGET_FOLDER}/km0_km4_app_ns.bin ${IMAGE_TARGET_FOLDER}/km0_km4_app_ns_tmp.bin
        )
        execute_process(
            COMMAND ${PADTOOL} ${IMAGE_TARGET_FOLDER}/km0_km4_app_tmp.bin 4096
        )
        execute_process(
            COMMAND ${PADTOOL} ${IMAGE_TARGET_FOLDER}/km0_km4_app_ns_tmp.bin 4096
        )
        execute_process(
            COMMAND ${PREPENDTOOL} ${BASEDIR}/amebadplus_gcc_project/fatfs.bin  VFS1_FLASH_BASE_ADDR  ${IMAGE_TARGET_FOLDER}/target_img2.map
        )
        execute_process(
            COMMAND ${CMAKE_COMMAND} -E cat ${IMAGE_TARGET_FOLDER}/km0_km4_app_tmp.bin ${BASEDIR}/amebadplus_gcc_project/fatfs_prepend.bin
            OUTPUT_FILE ${IMAGE_TARGET_FOLDER}/km0_km4_app.bin
        )
        execute_process(
            COMMAND ${CMAKE_COMMAND} -E cat ${IMAGE_TARGET_FOLDER}/km0_km4_app_ns_tmp.bin ${BASEDIR}/amebadplus_gcc_project/fatfs_prepend.bin
            OUTPUT_FILE ${IMAGE_TARGET_FOLDER}/km0_km4_app_ns.bin
        )
    endif()
endif()

if(CONFIG_COMPRESS_OTA_IMG)
    if(EXISTS ${IMAGE_TARGET_FOLDER}/km0_km4_app.bin)
        execute_process(
            COMMAND ${COMPRESSTOOL} ${IMAGE_TARGET_FOLDER}/km0_km4_app.bin
        )
        execute_process(
            COMMAND ${COMPRESSTOOL} ${IMAGE_TARGET_FOLDER}/km0_km4_app_ns.bin
        )
        execute_process(
            COMMAND ${CMAKE_COMMAND} -E copy ${IMAGE_TARGET_FOLDER}/km0_km4_app_compress.bin ${IMAGE_TARGET_FOLDER}/tmp_app.bin
        )
        execute_process(
            COMMAND ${CMAKE_COMMAND} -E copy ${IMAGE_TARGET_FOLDER}/km0_km4_app_ns_compress.bin ${IMAGE_TARGET_FOLDER}/tmp_app_ns.bin
        )
    endif()
else()
    if(EXISTS ${IMAGE_TARGET_FOLDER}/km0_km4_app.bin)
        execute_process(
            COMMAND ${CMAKE_COMMAND} -E copy ${IMAGE_TARGET_FOLDER}/km0_km4_app.bin ${IMAGE_TARGET_FOLDER}/tmp_app.bin
        )
        execute_process(
            COMMAND ${CMAKE_COMMAND} -E copy ${IMAGE_TARGET_FOLDER}/km0_km4_app_ns.bin ${IMAGE_TARGET_FOLDER}/tmp_app_ns.bin
        )
    endif()
endif()

if(CONFIG_UPGRADE_BOOTLOADER)
    if(EXISTS ${IMAGE_TARGET_FOLDER}/tmp_app.bin)
        execute_process(
            COMMAND ${OTAPREPENDTOOL} ${IMAGE_TARGET_FOLDER}/tmp_app.bin ${IMAGE_TARGET_FOLDER}/km4_boot_all.bin
        )
        execute_process(
            COMMAND ${OTAPREPENDTOOL} ${IMAGE_TARGET_FOLDER}/tmp_app_ns.bin ${IMAGE_TARGET_FOLDER}/km4_boot_all_ns.bin
        )
    endif()
else()
    if(EXISTS ${IMAGE_TARGET_FOLDER}/tmp_app.bin)
        execute_process(
            COMMAND ${OTAPREPENDTOOL} ${IMAGE_TARGET_FOLDER}/tmp_app.bin
        )
        execute_process(
            COMMAND ${OTAPREPENDTOOL} ${IMAGE_TARGET_FOLDER}/tmp_app_ns.bin
        )
    endif()
endif()

execute_process(
    COMMAND ${CMAKE_COMMAND} -E remove ${IMAGE_TARGET_FOLDER}/tmp_app.bin
)
execute_process(
    COMMAND ${CMAKE_COMMAND} -E remove ${IMAGE_TARGET_FOLDER}/tmp_app_ns.bin
)
message("========== Image manipulating end ==========")

if (CONFIG_MP_INCLUDED)
    set(APP_ALL ${IMAGE_TARGET_FOLDER}/km0_km4_app_mp.bin)
else()
    set(APP_ALL	${IMAGE_TARGET_FOLDER}/km0_km4_app.bin)
endif()
set(OTA_ALL	${IMAGE_TARGET_FOLDER}/ota_all.bin)

if(EXISTS ${APP_ALL})
    execute_process(
        COMMAND ${CMAKE_COMMAND} -E copy ${APP_ALL} ${FINAL_IMAGE_DIR}
    )
endif()

if(EXISTS ${OTA_ALL})
    execute_process(
        COMMAND ${CMAKE_COMMAND} -E copy ${OTA_ALL} ${FINAL_IMAGE_DIR}
    )
endif()

if(NOT CONFIG_AMEBA_RLS)
    message("========== Image analyze start ==========")
    execute_process(
        COMMAND ${CODE_ANALYZE_PYTHON} ${ANALYZE_MP_IMG} ${DAILY_BUILD}
        WORKING_DIRECTORY ${PROJECTDIR}/asdk
    )
    execute_process(
        COMMAND ${STATIC_ANALYZE_PYTHON} ${DAILY_BUILD}
        WORKING_DIRECTORY ${PROJECTDIR}/asdk
    )
    message("========== Image analyze end ==========")
endif()
