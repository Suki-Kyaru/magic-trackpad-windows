cmake_minimum_required(VERSION 3.25)

project(MagicTrackpadWindows
    VERSION 0.1.0
    LANGUAGES CXX
)

include(CTest)

add_executable(MagicTrackpadHelper
    helper/main.cpp
)

target_compile_features(MagicTrackpadHelper PRIVATE cxx_std_20)

target_compile_definitions(MagicTrackpadHelper PRIVATE
    UNICODE
    _UNICODE
    WIN32_LEAN_AND_MEAN
    NOMINMAX
)

target_link_libraries(MagicTrackpadHelper PRIVATE
    setupapi
    cfgmgr32
    bthprops
)

if(MSVC)
    target_compile_options(MagicTrackpadHelper PRIVATE
        /W4
        /permissive-
        /utf-8
        /EHsc
    )
endif()
if(BUILD_TESTING)
    add_executable(MagicTrackpadStatusBindingTests
        tests/status_binding_tests.cpp
    )

    target_compile_features(
        MagicTrackpadStatusBindingTests
        PRIVATE cxx_std_20
    )

    target_compile_definitions(
        MagicTrackpadStatusBindingTests
        PRIVATE
            UNICODE
            _UNICODE
            WIN32_LEAN_AND_MEAN
            NOMINMAX
    )

    target_include_directories(
        MagicTrackpadStatusBindingTests
        PRIVATE
            ${CMAKE_CURRENT_SOURCE_DIR}
    )

    if(MSVC)
        target_compile_options(
            MagicTrackpadStatusBindingTests
            PRIVATE
                /W4
                /permissive-
                /utf-8
                /EHsc
        )
    endif()

    add_test(
        NAME status-binding
        COMMAND MagicTrackpadStatusBindingTests
    )
endif()
