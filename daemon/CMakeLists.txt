set(CMAKE_CXX_STANDARD 11)

set(SOURCES PRIVATE
        io.c
        io.h
        core.c
        core.h
        netutils.c
        netutils.h)

if (APPLE)
    list(APPEND SOURCES corewlan.m corewlan.h)
endif ()

add_executable(owl "")

target_sources(owl ${SOURCES} owl.c)

include_directories(/lib/arm-linux-gnueabihf)
include_directories(/usr/include/)

find_path(pcap_INCLUDE pcap.h PATHS /usr/include/ REQUIRED)
# change /lib/arm-linux-gnueabihf to aarch64-linux-gnu if you wish
find_library(pcap_LIBRARY pcap PATHS /lib/arm-linux-gnueabihf REQUIRED)

find_path(ev_INCLUDE ev.h PATHS /usr/include/ REQUIRED)
find_library(ev_LIBRARY ev PATHS /lib/arm-linux-gnueabihf REQUIRED)

if (APPLE)
    find_library(FOUNDATION Foundation REQUIRED)
    find_library(COREWLAN CoreWLAN REQUIRED)
    find_library(SYSTEMCONFIGURATION SystemConfiguration REQUIRED)
else ()
    find_path(nl_INCLUDE netlink/version.h PATH_SUFFIXES libnl3 REQUIRED)
    find_library(nl_LIBRARY nl-3 PATHS /lib/arm-linux-gnueabihf REQUIRED)
    find_library(nlgenl_LIBRARY nl-genl-3 PATHS /lib/arm-linux-gnueabihf REQUIRED)
    find_library(nlroute_LIBRARY nl-route-3 PATHS /lib/arm-linux-gnueabihf REQUIRED)
endif ()

target_include_directories(owl PRIVATE ${CMAKE_SOURCE_DIR}/src ${ev_INCLUDE} ${pcap_INCLUDE})

target_link_libraries(owl awdl ${pcap_LIBRARY} ${ev_LIBRARY})
if (APPLE)
    target_link_libraries(owl ${FOUNDATION} ${COREWLAN} ${SYSTEMCONFIGURATION})
else ()
    target_include_directories(owl PRIVATE ${nl_INCLUDE})
    target_link_libraries(owl ${nl_LIBRARY} ${nlgenl_LIBRARY} ${nlroute_LIBRARY})
endif ()

install(TARGETS owl DESTINATION bin)
