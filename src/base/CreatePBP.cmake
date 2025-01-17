# File defining macro outputting PSP-specific EBOOT.PBP out of passed executable target.
#
# Copyright 2020 - Daniel 'dbeef' Zalega
# Copyright 2021 - max_ishere

cmake_minimum_required(VERSION 3.10)

macro(create_pbp_file)

  set(oneValueArgs
    TARGET          # defined by an add_executable call before calling create_pbp_file
    TITLE           # optional, string, target's name in PSP menu
    ICON_PATH       # optional, absolute path to .png file, 144x82
    BACKGROUND_PATH # optional, absolute path to .png file, 480x272
    PREVIEW_PATH    # optional, absolute path to .png file, 480x272
    )
  set(options
    BUILD_PRX # optional, generates and uses PRX file instead of ELF in EBOOT.PBP
    ENC_PRX   # optional, replaces PRX file with encrypted version.
    )
  cmake_parse_arguments("ARG" "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  # As pack-pbp takes undefined arguments in form of "NULL" string,
  # set each undefined macro variable to such value:
  foreach(arg ${oneValueArgs})
    if (NOT DEFINED ARG_${arg})
      set(ARG_${arg} "NULL")
    endif()
  endforeach()

  if(NOT ${ARG_BUILD_PRX} AND ${ARG_ENC_PRX})
    message(WARNING "You are asking to encrypt PRX that is not built by this macro.\n"
      "ENC_PRX flag for target '${ARG_TARGET}' will be ignored.")
  endif()

  if(${ARG_BUILD_PRX})
    target_link_options(${ARG_TARGET}
      PUBLIC -specs=${PSPDEV}/psp/sdk/lib/prxspecs
      PUBLIC -Wl,-q,-T${PSPDEV}/psp/sdk/lib/linkfile.prx
      PUBLIC ${PSPDEV}/psp/sdk/lib/prxexports.o)
  endif()

  if("${CMAKE_BUILD_TYPE}" STREQUAL "Release" AND NOT ${ARG_BUILD_PRX})
    add_custom_command(
      TARGET ${ARG_TARGET}
      POST_BUILD COMMAND
      "${PSPDEV}/bin/psp-strip" "$<TARGET_FILE:${ARG_TARGET}>"
      COMMENT "Stripping binary"
      )
  elseif(${ARG_BUILD_PRX})
    add_custom_command(
      TARGET ${ARG_TARGET}
      POST_BUILD COMMAND
      ${CMAKE_COMMAND} -E cmake_echo_color --cyan "Not stripping binary because building PRX."
      )
  else()
    add_custom_command(
      TARGET ${ARG_TARGET}
      POST_BUILD COMMAND
      ${CMAKE_COMMAND} -E cmake_echo_color --cyan "Not stripping binary, build type is ${CMAKE_BUILD_TYPE}."
      )
  endif()

  add_custom_command(
    TARGET ${ARG_TARGET} POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E make_directory
    $<TARGET_FILE_DIR:${ARG_TARGET}>/psp_artifact
    COMMENT "Creating psp_artifact directory."
    )

  add_custom_command(
    TARGET ${ARG_TARGET} POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
    $<TARGET_FILE:${ARG_TARGET}>
    "$<TARGET_FILE_DIR:${ARG_TARGET}>/psp_artifact/${ARG_TARGET}.elf"
    COMMENT "Copying ELF to psp_arfitact directory."
    )

  add_custom_command(
    TARGET ${ARG_TARGET}
    POST_BUILD COMMAND
    "$ENV{PSPDEV}/bin/psp-fixup-imports" "$<TARGET_FILE_DIR:${ARG_TARGET}>/psp_artifact/${ARG_TARGET}.elf"
    COMMENT "Calling psp-fixup-imports"
    )

  if (${ARG_BUILD_PRX})
    add_custom_command(
      TARGET ${ARG_TARGET}
      POST_BUILD COMMAND
      "${PSPDEV}/bin/psp-prxgen" "$<TARGET_FILE_DIR:${ARG_TARGET}>/psp_artifact/${ARG_TARGET}.elf"
      "$<TARGET_FILE_DIR:${ARG_TARGET}>/psp_artifact/${ARG_TARGET}.prx"
      COMMENT "Calling prxgen"
      )

    if(${ARG_ENC_PRX})
      add_custom_command(
	TARGET ${ARG_TARGET}
	POST_BUILD COMMAND
	"${PSPDEV}/bin/PrxEncrypter" "$<TARGET_FILE_DIR:${ARG_TARGET}>/psp_artifact/${ARG_TARGET}.prx"
	"$<TARGET_FILE_DIR:${ARG_TARGET}>/psp_artifact/${ARG_TARGET}.prx"
	COMMENT "Calling PrxEncrypter"
	)
    else()
      add_custom_command(
	TARGET ${ARG_TARGET}
	POST_BUILD COMMAND
	${CMAKE_COMMAND} -E cmake_echo_color --cyan "Not encrypting PRX, use ENC_PRX flag if you need to."
	)
    endif()
    
  else()
    add_custom_command(
      TARGET ${ARG_TARGET}
      POST_BUILD COMMAND
      ${CMAKE_COMMAND} -E cmake_echo_color --cyan "Not building PRX"
      )
  endif()
  
  add_custom_command(
    TARGET ${ARG_TARGET}
    POST_BUILD COMMAND
    "${PSPDEV}/bin/mksfoex" "-d" "MEMSIZE=1" "${ARG_TITLE}" "PARAM.SFO"
    COMMENT "Calling mksfoex"
    )

  if(${ARG_BUILD_PRX})
    add_custom_command(
      TARGET ${ARG_TARGET}
      POST_BUILD COMMAND
      "${PSPDEV}/bin/pack-pbp" "EBOOT.PBP" "PARAM.SFO" "${ARG_ICON_PATH}" "NULL" "${ARG_PREVIEW_PATH}"
      "${ARG_BACKGROUND_PATH}" "NULL" "$<TARGET_FILE_DIR:${ARG_TARGET}>/psp_artifact/${ARG_TARGET}.prx" "NULL"
      COMMENT "Calling pack-pbp with PRX file"
      )
  else()
    add_custom_command(
      TARGET ${ARG_TARGET}
      POST_BUILD COMMAND
      "${PSPDEV}/bin/pack-pbp" "EBOOT.PBP" "PARAM.SFO" "${ARG_ICON_PATH}" "NULL" "${ARG_PREVIEW_PATH}"
      "${ARG_BACKGROUND_PATH}" "NULL" "$<TARGET_FILE_DIR:${ARG_TARGET}>/psp_artifact/${ARG_TARGET}.elf" "NULL"
      COMMENT "Calling pack-pbp with ELF file"
      )
  endif()

  add_custom_command(
    TARGET ${ARG_TARGET}
    POST_BUILD COMMAND
    ${CMAKE_COMMAND} -E cmake_echo_color --cyan "EBOOT.PBP file created."
    )
  
endmacro()
