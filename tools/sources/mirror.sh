#!/usr/bin/env bash
#####################
mirror_main() {
    case "$1" in
    --autoswitch)
        auto_check_distro_and_modify_sources_list
        ;;
    -p)
        tmoe_debian_add_ubuntu_ppa_source
        ;;
    -m | *)
        tmoe_sources_list_manager
        ;;
    esac
}
############################################
check_tmoe_sources_list_backup_file() {
    case "${LINUX_DISTRO}" in
    "debian")
        SOURCES_LIST_PATH="/etc/apt/"
        SOURCES_LIST_FILE="/etc/apt/sources.list"
        SOURCES_LIST_FILE_NAME="sources.list"
        SOURCES_LIST_BACKUP_FILE="${HOME}/.config/tmoe-linux/sources.list.bak"
        SOURCES_LIST_BACKUP_FILE_NAME="sources.list.bak"
        EXTRA_SOURCE='🐉debian更换为kali源'
        ;;
    "arch")
        SOURCES_LIST_PATH="/etc/pacman.d/"
        SOURCES_LIST_FILE="/etc/pacman.d/mirrorlist"
        SOURCES_LIST_FILE_NAME="mirrorlist"
        SOURCES_LIST_BACKUP_FILE="${HOME}/.config/tmoe-linux/pacman.d_mirrorlist.bak"
        SOURCES_LIST_BACKUP_FILE_NAME="pacman.d_mirrorlist.bak"
        EXTRA_SOURCE='archlinux_cn源'
        SOURCES_LIST_FILE_02="/etc/pacman.conf"
        SOURCES_LIST_BACKUP_FILE_02="${HOME}/.config/tmoe-linux/pacman.conf.bak"
        ;;
    "alpine")
        SOURCES_LIST_PATH="/etc/apk/"
        SOURCES_LIST_FILE="/etc/apk/repositories"
        SOURCES_LIST_FILE_NAME="repositories"
        SOURCES_LIST_BACKUP_FILE="${HOME}/.config/tmoe-linux/alpine_repositories.bak"
        SOURCES_LIST_BACKUP_FILE_NAME="alpine_repositories.bak"
        EXTRA_SOURCE='alpine额外源'
        ;;
    "redhat")
        SOURCES_LIST_PATH="/etc/yum.repos.d"
        SOURCES_LIST_BACKUP_FILE="${HOME}/.config/tmoe-linux/yum.repos.d-backup.tar.gz"
        SOURCES_LIST_BACKUP_FILE_NAME="yum.repos.d-backup.tar.gz"
        EXTRA_SOURCE='epel源'
        ;;
    *) EXTRA_SOURCE="不支持修改${LINUX_DISTRO}源" ;;
    esac

    if [ ! -e "${SOURCES_LIST_BACKUP_FILE}" ]; then
        mkdir -p "${HOME}/.config/tmoe-linux"
        if [ "${LINUX_DISTRO}" = "redhat" ]; then
            tar -Ppzcvf ${SOURCES_LIST_BACKUP_FILE} ${SOURCES_LIST_PATH}
        else
            cp -pf "${SOURCES_LIST_FILE}" "${SOURCES_LIST_BACKUP_FILE}"
        fi
    fi

    if [ "${LINUX_DISTRO}" = "arch" ]; then
        if [ ! -e "${SOURCES_LIST_BACKUP_FILE_02}" ]; then
            cp -pf "${SOURCES_LIST_FILE_02}" "${SOURCES_LIST_BACKUP_FILE_02}"
        fi
    fi
}
##########
modify_alpine_mirror_repositories() {
    ALPINE_VERSION=$(sed -n p /etc/os-release | grep 'PRETTY_NAME=' | head -n 1 | cut -d '=' -f 2 | cut -d '"' -f 2 | awk -F ' ' '$0=$NF')
    cd /etc/apk/
    if [ ! -z ${ALPINE_VERSION} ]; then
        sed -i 's@http@#&@g' repositories
        cat >>repositories <<-ENDofRepositories
			http://${SOURCE_MIRROR_STATION}/alpine/${ALPINE_VERSION}/main
			http://${SOURCE_MIRROR_STATION}/alpine/${ALPINE_VERSION}/community
		ENDofRepositories
    else
        sed -i "s@^http.*/alpine/@http://${SOURCE_MIRROR_STATION}/alpine/@g" repositories
    fi
    ${TMOE_UPDATE_COMMAND}
    apk upgrade
}
############################################
auto_check_distro_and_modify_sources_list() {
    if [ ! -z "${SOURCE_MIRROR_STATION}" ]; then
        case "${LINUX_DISTRO}" in
        "debian") check_debian_distro_and_modify_sources_list ;;
        "arch") check_arch_distro_and_modify_mirror_list ;;
        "alpine") modify_alpine_mirror_repositories ;;
        "redhat")
            case "${REDHAT_DISTRO}" in
            "fedora") check_fedora_versio ;;
            *) printf "%s\n" "Sorry,本功能不支持${LINUX_DISTRO}" ;;
            esac
            ;;
        esac
    fi
    ################
    press_enter_to_return
}
##############################
china_university_mirror_station() {
    SOURCE_MIRROR_STATION=""
    RETURN_TO_WHERE='china_university_mirror_station'
    SOURCES_LIST=$(
        whiptail --title "软件源列表" --menu \
            "您想要切换为哪个镜像站呢？\n目前仅支持debian,ubuntu,kali,arch,manjaro,fedora和alpine" 0 50 0 \
            "1" "清华大学mirrors.tuna.tsinghua.edu.cn" \
            "2" "tuna姊妹站,北京外国语大学mirrors.bfsu.edu.cn" \
            "3" "tuna兄弟站opentuna.cn" \
            "4" "中国科学技术大学mirrors.ustc.edu.cn" \
            "5" "浙江大学mirrors.zju.edu.cn" \
            "6" "上海交通大学mirror.sjtu.edu.cn" \
            "7" "华中科技大学mirrors.hust.edu.cn" \
            "8" "北京理工大学mirror.bit.edu.cn" \
            "9" "北京交通大学mirror.bjtu.edu.cn" \
            "10" "兰州大学mirror.lzu.edu.cn" \
            "11" "大连东软信息学院mirrors.neusoft.edu.cn" \
            "12" "南京大学mirrors.nju.edu.cn" \
            "13" "南京邮电大学mirrors.njupt.edu.cn" \
            "14" "西北农林科技大学mirrors.nwafu.edu.cn" \
            "0" "🌚 Return to previous menu 返回上级菜单" \
            3>&1 1>&2 2>&3
    )
    ########################
    case "${SOURCES_LIST}" in
    0 | "") tmoe_sources_list_manager ;;
    1) SOURCE_MIRROR_STATION='mirrors.tuna.tsinghua.edu.cn' ;;
    2) SOURCE_MIRROR_STATION='mirrors.bfsu.edu.cn' ;;
    3) SOURCE_MIRROR_STATION='opentuna.cn' ;;
    4) SOURCE_MIRROR_STATION='mirrors.ustc.edu.cn' ;;
    5) SOURCE_MIRROR_STATION='mirrors.zju.edu.cn' ;;
    6) SOURCE_MIRROR_STATION='mirror.sjtu.edu.cn' ;;
    7) SOURCE_MIRROR_STATION='mirrors.hust.edu.cn' ;;
    8) SOURCE_MIRROR_STATION='mirror.bit.edu.cn' ;;
    9) SOURCE_MIRROR_STATION='mirror.bjtu.edu.cn' ;;
    10) SOURCE_MIRROR_STATION='mirror.lzu.edu.cn' ;;
    11) SOURCE_MIRROR_STATION='mirrors.neusoft.edu.cn' ;;
    12) SOURCE_MIRROR_STATION='mirrors.nju.edu.cn' ;;
    13) SOURCE_MIRROR_STATION='mirrors.njupt.edu.cn' ;;
    14) SOURCE_MIRROR_STATION='mirrors.nwafu.edu.cn' ;;
    esac
    ######################################
    auto_check_distro_and_modify_sources_list
    ##########
    china_university_mirror_station
}
#############
china_bussiness_mirror_station() {
    SOURCE_MIRROR_STATION=""
    RETURN_TO_WHERE='china_bussiness_mirror_station'
    SOURCES_LIST=$(
        whiptail --title "软件源列表" --menu \
            "您想要切换为哪个镜像源呢？\n目前仅支持debian,ubuntu,kali,arch,manjaro,fedora和alpine" 0 50 0 \
            "1" "mirrors.huaweicloud.com华为云" \
            "2" "mirrors.cloud.tencent.com腾讯云" \
            "3" "mirrors.aliyun.com阿里云" \
            "4" "mirrors.163.com网易" \
            "5" "mirrors.cnnic.cn中国互联网络信息中心" \
            "6" "mirrors.sohu.com搜狐" \
            "7" "mirrors.yun-idc.com首都在线" \
            "0" "🌚 Return to previous menu 返回上级菜单" \
            3>&1 1>&2 2>&3
    )
    ########################
    case "${SOURCES_LIST}" in
    0 | "") tmoe_sources_list_manager ;;
    1) SOURCE_MIRROR_STATION='mirrors.huaweicloud.com' ;;
    2) SOURCE_MIRROR_STATION='mirrors.cloud.tencent.com' ;;
    3) SOURCE_MIRROR_STATION='mirrors.aliyun.com' ;;
    4) SOURCE_MIRROR_STATION='mirrors.163.com' ;;
    5) SOURCE_MIRROR_STATION='mirrors.cnnic.cn' ;;
    6) SOURCE_MIRROR_STATION='mirrors.sohu.com' ;;
    7) SOURCE_MIRROR_STATION='mirrors.yun-idc.com' ;;
    esac
    ######################################
    auto_check_distro_and_modify_sources_list
    china_bussiness_mirror_station
}
###########
sed_a_source_list() {
    TMOE_LINUX_DIR='/usr/local/etc/tmoe-linux'
    TMOE_GIT_DIR="${TMOE_LINUX_DIR}/git"
    TMOE_SHARE_DIR="${TMOE_GIT_DIR}/share"
    TMOE_MIRROR_DIR="${TMOE_SHARE_DIR}/configuration/mirror-list"
    SOURCE_LIST='/etc/apt/sources.list'
    MIRROR_LIST='/etc/pacman.d/mirrorlist'
    SOURCELISTCODE=$(sed -n p /etc/os-release | grep VERSION_CODENAME | cut -d '=' -f 2 | head -n 1)
    BACKPORTCODE=$(sed -n p /etc/os-release | grep PRETTY_NAME | head -n 1 | cut -d '=' -f 2 | cut -d '"' -f 2 | awk -F ' ' '$0=$NF' | cut -d '/' -f 1 | cut -d '(' -f 2 | cut -d ')' -f 1)
    if egrep -q 'debian|ubuntu' /etc/os-release; then
        SOURCELISTCODE=$(sed -n p /etc/os-release | grep VERSION_CODENAME | cut -d '=' -f 2 | head -n 1)
        BACKPORTCODE=$(sed -n p /etc/os-release | grep PRETTY_NAME | head -n 1 | cut -d '=' -f 2 | cut -d '"' -f 2 | awk -F ' ' '$0=$NF' | cut -d '/' -f 1 | cut -d '(' -f 2 | cut -d ')' -f 1)
        if ! grep -q '#Official' ${SOURCE_LIST}; then
            if grep -q 'Debian' /etc/issue 2>/dev/null; then
                if [ "$(lsb_release -r | awk '{print $2}' | awk -F '/' '{print $1}')" = 'unstable' ]; then
                    #sed -i "$ r ${TMOE_MIRROR_DIR}/debian/sources.list;s@testing@${BACKPORTCODE}@g" ${SOURCE_LIST}
                    sed -i "$ r ${TMOE_MIRROR_DIR}/debian/sid.list" ${SOURCE_LIST}
                else
                    cp -f ${TMOE_MIRROR_DIR}/debian/sources.list /tmp
                    sed -i "s@testing@${BACKPORTCODE}@g" /tmp/sources.list
                    sed -i '$ r /tmp/sources.list' ${SOURCE_LIST}
                fi
            elif grep -q "ubuntu" /etc/os-release; then
                case $(uname -m) in
                i*86 | x86_64)
                    #sed -i "$ r ${TMOE_MIRROR_DIR}/ubuntu/amd64/sources.list;s@focal@${SOURCELISTCODE}@g" ${SOURCE_LIST}
                    cp -f ${TMOE_MIRROR_DIR}/ubuntu/amd64/sources.list /tmp
                    sed -i "s@focal@${SOURCELISTCODE}@g" /tmp/sources.list
                    sed -i '$ r /tmp/sources.list' ${SOURCE_LIST}
                    ;;
                esac
            fi
        fi
        if [ $(command -v editor) ]; then
            editor ${SOURCE_LIST}
        else
            nano ${SOURCE_LIST}
        fi
    elif grep -q 'Arch' /etc/issue 2>/dev/null; then
        if ! grep -q '## Worldwide' ${MIRROR_LIST}; then
            case $(uname -m) in
            i*86 | x86_64) sed -i "$ r ${TMOE_MIRROR_DIR}/arch/x86_64/mirrorlist" ${MIRROR_LIST} ;;
            *) sed -i "$ r ${TMOE_MIRROR_DIR}/arch/aarch64/mirrorlist" ${MIRROR_LIST} ;;
            esac
        fi
        if [ $(command -v vim) ]; then
            vim ${MIRROR_LIST}
        else
            nano ${MIRROR_LIST}
        fi
    fi
}
###############
worldwide_mirror_station() {
    SOURCE_MIRROR_STATION=""
    RETURN_TO_WHERE='worldwide_mirror_station'
    DEBIAN_SECURITY_SOURCE='true'
    SOURCES_LIST=$(
        whiptail --title "www.debian.org/mirror/list.html" --menu \
            "Not only debian,but also ubuntu." 0 50 0 \
            "0" "🌚 Return to previous menu 返回上级菜单" \
            "000" "Generate worldwide source(arch,ubuntu,debian)" \
            "00" "official官方:(debian,ubuntu,kali)" \
            "01" "Armenia:ftp.am.debian.org" \
            "02" "Australia:ftp.au.debian.org" \
            "03" "Austria:ftp.at.debian.org" \
            "04" "Belarus:ftp.by.debian.org" \
            "05" "Belgium:ftp.be.debian.org" \
            "06" "Brazil:ftp.br.debian.org" \
            "07" "Bulgaria:ftp.bg.debian.org" \
            "08" "Canada:ftp.ca.debian.org" \
            "09" "Chile:ftp.cl.debian.org" \
            "10" "清华:ftp2.cn.debian.org" \
            "11" "中科大:ftp.cn.debian.org" \
            "12" "Croatia:ftp.hr.debian.org" \
            "13" "Czech Republic:ftp.cz.debian.org" \
            "14" "Denmark:ftp.dk.debian.org" \
            "15" "El Salvador:ftp.sv.debian.org" \
            "16" "Estonia:ftp.ee.debian.org" \
            "17" "France:ftp.fr.debian.org" \
            "18" "Germany:ftp2.de.debian.org" \
            "19" "Germany:ftp.de.debian.org" \
            "20" "Greece:ftp.gr.debian.org" \
            "21" "香港:ftp.hk.debian.org" \
            "22" "Hungary:ftp.hu.debian.org" \
            "23" "Italy:ftp.it.debian.org" \
            "24" "日本:ftp.jp.debian.org" \
            "25" "한국:ftp.kr.debian.org" \
            "26" "Lithuania:ftp.lt.debian.org" \
            "27" "Mexico:ftp.mx.debian.org" \
            "28" "Moldova:ftp.md.debian.org" \
            "29" "Netherlands:ftp.nl.debian.org" \
            "30" "New Caledonia:ftp.nc.debian.org" \
            "31" "New Zealand:ftp.nz.debian.org" \
            "32" "Norway:ftp.no.debian.org" \
            "33" "Poland:ftp.pl.debian.org" \
            "34" "Portugal:ftp.pt.debian.org" \
            "35" "Romania:ftp.ro.debian.org" \
            "36" "Russia:ftp.ru.debian.org" \
            "37" "Slovakia:ftp.sk.debian.org" \
            "38" "Slovenia:ftp.si.debian.org" \
            "39" "Spain:ftp.es.debian.org" \
            "40" "Sweden:ftp.fi.debian.org" \
            "41" "Sweden:ftp.se.debian.org" \
            "42" "Switzerland:ftp.ch.debian.org" \
            "43" "自由軟體實驗室:ftp.tw.debian.org" \
            "44" "Turkey:ftp.tr.debian.org" \
            "45" "United Kingdom:ftp.is.debian.org" \
            "46" "United Kingdom:ftp.uk.debian.org" \
            "47" "United States:ftp.us.debian.org" \
            3>&1 1>&2 2>&3
    )
    ########################
    case "${SOURCES_LIST}" in
    0 | "") tmoe_sources_list_manager ;;
    000)
        case ${LINUX_DISTRO} in
        debian | arch) sed_a_source_list ;;
        *) printf "%s\n" "This tool does not support your current distro." ;;
        esac
        press_enter_to_return
        worldwide_mirror_station
        ;;
    00)
        case ${LINUX_DISTRO} in
        debian)
            SOURCE_MIRROR_STATION='deb.debian.org'
            case "${DEBIAN_DISTRO}" in
            ubuntu) SOURCE_MIRROR_STATION='archive.ubuntu.com' ;;
            kali) SOURCE_MIRROR_STATION='http.kali.org' ;;
            esac
            ;;
        esac
        ;;
    01) SOURCE_MIRROR_STATION='ftp.am.debian.org' ;;
    02) SOURCE_MIRROR_STATION='ftp.au.debian.org' ;;
    03) SOURCE_MIRROR_STATION='ftp.at.debian.org' ;;
    04) SOURCE_MIRROR_STATION='ftp.by.debian.org' ;;
    05) SOURCE_MIRROR_STATION='ftp.be.debian.org' ;;
    06) SOURCE_MIRROR_STATION='ftp.br.debian.org' ;;
    07) SOURCE_MIRROR_STATION='ftp.bg.debian.org' ;;
    08) SOURCE_MIRROR_STATION='ftp.ca.debian.org' ;;
    09) SOURCE_MIRROR_STATION='ftp.cl.debian.org' ;;
    10) SOURCE_MIRROR_STATION='ftp2.cn.debian.org' ;;
    11) SOURCE_MIRROR_STATION='ftp.cn.debian.org' ;;
    12) SOURCE_MIRROR_STATION='ftp.hr.debian.org' ;;
    13) SOURCE_MIRROR_STATION='ftp.cz.debian.org' ;;
    14) SOURCE_MIRROR_STATION='ftp.dk.debian.org' ;;
    15) SOURCE_MIRROR_STATION='ftp.sv.debian.org' ;;
    16) SOURCE_MIRROR_STATION='ftp.ee.debian.org' ;;
    17) SOURCE_MIRROR_STATION='ftp.fr.debian.org' ;;
    18) SOURCE_MIRROR_STATION='ftp2.de.debian.org' ;;
    19) SOURCE_MIRROR_STATION='ftp.de.debian.org' ;;
    20) SOURCE_MIRROR_STATION='ftp.gr.debian.org' ;;
    21) SOURCE_MIRROR_STATION='ftp.hk.debian.org' ;;
    22) SOURCE_MIRROR_STATION='ftp.hu.debian.org' ;;
    23) SOURCE_MIRROR_STATION='ftp.it.debian.org' ;;
    24) SOURCE_MIRROR_STATION='ftp.jp.debian.org' ;;
    25) SOURCE_MIRROR_STATION='ftp.kr.debian.org' ;;
    26) SOURCE_MIRROR_STATION='ftp.lt.debian.org' ;;
    27) SOURCE_MIRROR_STATION='ftp.mx.debian.org' ;;
    28) SOURCE_MIRROR_STATION='ftp.md.debian.org' ;;
    29) SOURCE_MIRROR_STATION='ftp.nl.debian.org' ;;
    30) SOURCE_MIRROR_STATION='ftp.nc.debian.org' ;;
    31) SOURCE_MIRROR_STATION='ftp.nz.debian.org' ;;
    32) SOURCE_MIRROR_STATION='ftp.no.debian.org' ;;
    33) SOURCE_MIRROR_STATION='ftp.pl.debian.org' ;;
    34) SOURCE_MIRROR_STATION='ftp.pt.debian.org' ;;
    35) SOURCE_MIRROR_STATION='ftp.ro.debian.org' ;;
    36) SOURCE_MIRROR_STATION='ftp.ru.debian.org' ;;
    37) SOURCE_MIRROR_STATION='ftp.sk.debian.org' ;;
    38) SOURCE_MIRROR_STATION='ftp.si.debian.org' ;;
    39) SOURCE_MIRROR_STATION='ftp.es.debian.org' ;;
    40) SOURCE_MIRROR_STATION='ftp.fi.debian.org' ;;
    41) SOURCE_MIRROR_STATION='ftp.se.debian.org' ;;
    42) SOURCE_MIRROR_STATION='ftp.ch.debian.org' ;;
    43) SOURCE_MIRROR_STATION='ftp.tw.debian.org' ;;
    44) SOURCE_MIRROR_STATION='ftp.tr.debian.org' ;;
    45) SOURCE_MIRROR_STATION='ftp.is.debian.org' ;;
    46) SOURCE_MIRROR_STATION='ftp.uk.debian.org' ;;
    47) SOURCE_MIRROR_STATION='ftp.us.debian.org' ;;
    esac
    ######################################
    auto_check_distro_and_modify_sources_list
    worldwide_mirror_station
}
#####################################
tmoe_sources_list_manager() {
    DEBIAN_SECURITY_SOURCE='false'
    check_tmoe_sources_list_backup_file
    SOURCE_MIRROR_STATION=""
    RETURN_TO_WHERE='tmoe_sources_list_manager'
    SOURCES_LIST=$(
        whiptail --title "software-sources tmoe-manager" --menu \
            "您想要对软件源进行何种管理呢？" 17 50 9 \
            "1" "business:国内商业镜像源" \
            "2" "university:国内高校镜像源" \
            "3" "worldwide mirror sites:全球镜像站" \
            "4" "ping(镜像站延迟测试)" \
            "5" "speed(镜像站下载速度测试)" \
            "6" "+ppa:(🍥debian添加ubuntu ppa源)" \
            "7" "restore to default(还原默认源)" \
            "8" "edit list manually(手动编辑)" \
            "9" "${EXTRA_SOURCE}" \
            "10" "FAQ(常见问题)" \
            "11" "http/https" \
            "12" "delete invalid rows(去除无效行)" \
            "13" "trust(强制信任软件源)" \
            "0" "Back 返回" \
            3>&1 1>&2 2>&3
    )
    ########################
    case "${SOURCES_LIST}" in
    0 | "")
        case ${RETURN_TO_MENU} in
        "") tmoe_linux_tool_menu ;;
        *) ${RETURN_TO_MENU} ;;
        esac
        ;;
    1) china_bussiness_mirror_station ;;
    2) china_university_mirror_station ;;
    3) worldwide_mirror_station ;;
    4) ping_mirror_sources_list ;;
    5) mirror_sources_station_download_speed_test ;;
    6) tmoe_debian_add_ubuntu_ppa_source ;;
    7) restore_default_sources_list ;;
    8) edit_sources_list_manually ;;
    9) add_extra_source_list ;;
    10) sources_list_faq ;;
    11) switch_sources_http_and_https ;;
    12) delete_sources_list_invalid_rows ;;
    13) mandatory_trust_software_sources ;;
    esac
    ##########
    press_enter_to_return
    tmoe_sources_list_manager
}
######################
mandatory_trust_software_sources() {
    if (whiptail --title "您想要对这个小可爱做什么 " --yes-button "trust" --no-button "untrust" --yesno "您是想要强制信任还是取消信任呢？\nDo you want to trust sources list?♪(^∇^*) " 0 50); then
        trust_sources_list
    else
        untrust_sources_list
    fi
    ${TMOE_UPDATE_COMMAND}
}
##############
untrust_sources_list() {
    case "${LINUX_DISTRO}" in
    "debian") sed -i 's@^deb.*http@deb http@g' /etc/apt/sources.list ;;
    "arch") sed -i 's@SigLevel = Never@#SigLevel = Optional TrustAll@' "/etc/pacman.conf" ;;
    *) EXTRA_SOURCE='不支持修改${LINUX_DISTRO}源' ;;
    esac
}
#######################
trust_sources_list() {
    printf "%s\n" "执行此操作可能会有未知风险"
    do_you_want_to_continue
    case "${LINUX_DISTRO}" in
    "debian") sed -i 's@^deb.*http@deb [trusted=yes] http@g' /etc/apt/sources.list ;;
    "arch") sed -i 's@^#SigLevel.*@SigLevel = Never@' "/etc/pacman.conf" ;;
    *) EXTRA_SOURCE='不支持修改${LINUX_DISTRO}源' ;;
    esac
}
#####################
delete_sources_list_invalid_rows() {
    printf "%s\n" "执行此操作将删除软件源列表内的所有注释行,并自动去除重复行"
    do_you_want_to_continue
    case "${LINUX_DISTRO}" in
    "debian") sed -i '/^#/d' ${SOURCES_LIST_FILE} ;;
    "arch") sed -i '/^#Server.*=/d' ${SOURCES_LIST_FILE} ;;
    "alpine") sed -i '/^#.*http/d' ${SOURCES_LIST_FILE} ;;
    *) EXTRA_SOURCE='不支持修改${LINUX_DISTRO}源' ;;
    esac
    sort -u ${SOURCES_LIST_FILE} -o ${SOURCES_LIST_FILE}
    ${TMOE_UPDATE_COMMAND}
}
###################
sources_list_faq() {
    printf "%s\n" "若换源后更新软件数据库失败，则请切换为http源"
    case "${LINUX_DISTRO}" in
    "debian" | "arch") printf "%s\n" "然后选择强制信任软件源的功能。" ;;
    esac
    printf "%s\n" "若再次出错，则请更换为其它镜像源。"
}
################
switch_sources_list_to_http() {
    if [ "${LINUX_DISTRO}" = "redhat" ]; then
        sed -i 's@https://@http://@g' ${SOURCES_LIST_PATH}/*repo
    else
        sed -i 's@https://@http://@g' ${SOURCES_LIST_FILE}
    fi
}
######################
switch_sources_list_to_http_tls() {
    if [ "${LINUX_DISTRO}" = "redhat" ]; then
        sed -i 's@http://@https://@g' ${SOURCES_LIST_PATH}/*repo
    else
        sed -i 's@http://@https://@g' ${SOURCES_LIST_FILE}
    fi
}
#################
switch_sources_http_and_https() {
    if (whiptail --title "您想要对这个小可爱做什么 " --yes-button "http" --no-button "https" --yesno "您是想要将软件源切换为http还是https呢？♪(^∇^*) " 0 50); then
        switch_sources_list_to_http
    else
        switch_sources_list_to_http_tls
    fi
    ${TMOE_UPDATE_COMMAND}
}
###################
check_fedora_version() {
    FEDORA_VERSION="$(sed -n p /etc/os-release | grep 'VERSION_ID' | cut -d '=' -f 2)"
    if ((${FEDORA_VERSION} >= 30)); then
        if ((${FEDORA_VERSION} >= 32)); then
            fedora_32_repos
        else
            fedora_31_repos
        fi
        fedora_3x_repos
        #${TMOE_UPDATE_COMMAND}
        dnf makecache
    else
        printf "%s\n" "Sorry,不支持fedora29及其以下的版本"
    fi
}
######################
add_extra_source_list() {
    case "${LINUX_DISTRO}" in
    "debian") modify_to_kali_sources_list ;;
    "arch") add_arch_linux_cn_mirror_list ;;
    "redhat") add_fedora_epel_yum_repo ;;
    *) non_debian_function ;;
    esac
}
################
add_fedora_epel_yum_repo() {
    dnf install -y epel-release || yum install -y epel-release
    cp -pvf /etc/yum.repos.d/epel.repo /etc/yum.repos.d/epel.repo.backup
    cp -pvf /etc/yum.repos.d/epel-testing.repo /etc/yum.repos.d/epel-testing.repo.backup
    sed -e 's!^metalink=!#metalink=!g' \
        -e 's!^#baseurl=!baseurl=!g' \
        -e 's!//download\.fedoraproject\.org/pub!//mirrors.tuna.tsinghua.edu.cn!g' \
        -e 's!http://mirrors\.tuna!https://mirrors.tuna!g' \
        -i /etc/yum.repos.d/epel.repo /etc/yum.repos.d/epel-testing.repo
}
###############
add_arch_linux_cn_mirror_list() {
    if ! grep -q 'archlinuxcn' /etc/pacman.conf; then
        cat >>/etc/pacman.conf <<-'Endofpacman'
			[archlinuxcn]
			Server = https://mirrors.tuna.tsinghua.edu.cn/archlinuxcn/$arch
		Endofpacman
        pacman -Syu --noconfirm archlinux-keyring
        pacman -Sy --noconfirm archlinuxcn-keyring
    else
        printf "%s\n" "检测到您已添加archlinux_cn源"
    fi

    if [ ! $(command -v yay) ]; then
        pacman -S --noconfirm yay
        yay --aururl "https://aur.tuna.tsinghua.edu.cn" --save
    fi
}
###############
check_debian_distro_and_modify_sources_list() {
    case "${DEBIAN_DISTRO}" in
    "ubuntu") modify_ubuntu_mirror_sources_list ;;
    "kali") modify_kali_mirror_sources_list ;;
    *) modify_debian_mirror_sources_list ;;
    esac
    check_ca_certificates_and_apt_update
}
##############
check_arch_distro_and_modify_mirror_list() {
    sed -i 's/^Server/#&/g' /etc/pacman.d/mirrorlist
    if [ "$(sed -n p /etc/issue | cut -c 1-4)" = "Arch" ]; then
        modify_archlinux_mirror_list
    elif [ "$(sed -n p /etc/issue | cut -c 1-7)" = "Manjaro" ]; then
        modify_manjaro_mirror_list
    fi
    #${TMOE_UPDATE_COMMAND}
    pacman -Syyu
}
##############
modify_manjaro_mirror_list() {
    case "${ARCH_TYPE}" in
    "arm64" | "armhf")
        cat >>/etc/pacman.d/mirrorlist <<-EndOfArchMirrors
			#Server = https://${SOURCE_MIRROR_STATION}/archlinuxarm/\$arch/\$repo
			Server = https://${SOURCE_MIRROR_STATION}/manjaro/arm-stable/\$repo/\$arch
		EndOfArchMirrors
        ;;
    *)
        cat >>/etc/pacman.d/mirrorlist <<-EndOfArchMirrors
			#Server = https://${SOURCE_MIRROR_STATION}/archlinux/\$repo/os/\$arch
			Server = https://${SOURCE_MIRROR_STATION}/manjaro/stable/\$repo/\$arch
		EndOfArchMirrors
        ;;
    esac
}
###############
modify_archlinux_mirror_list() {
    case "${ARCH_TYPE}" in
    "arm64" | "armhf")
        cat >>/etc/pacman.d/mirrorlist <<-EndOfArchMirrors
			#Server = https://mirror.archlinuxarm.org/\$arch/\$repo
			Server = https://${SOURCE_MIRROR_STATION}/archlinuxarm/\$arch/\$repo
		EndOfArchMirrors
        ;;
    *)
        cat >>/etc/pacman.d/mirrorlist <<-EndOfArchMirrors
			#Server = http://mirrors.kernel.org/archlinux/\$repo/os/\$arch
			Server = https://${SOURCE_MIRROR_STATION}/archlinux/\$repo/os/\$arch
		EndOfArchMirrors
        ;;
    esac
}
###############
edit_sources_list_manually() {
    case "${LINUX_DISTRO}" in
    "debian")
        apt edit-sources || nano ${SOURCES_LIST_FILE}
        #SOURCES_LIST_FILE="/etc/apt/sources.list"
        if [ ! -z "$(ls /etc/apt/sources.list.d/)" ]; then
            nano /etc/apt/sources.list.d/*.list
        fi
        ;;
    "redhat") nano ${SOURCES_LIST_PATH}/*repo ;;
    "arch") nano ${SOURCES_LIST_FILE} /etc/pacman.conf ;;
    *) nano ${SOURCES_LIST_FILE} ;;
    esac
}
##########
download_debian_ls_lr() {
    printf "%s\n" "${BLUE}${SOURCE_MIRROR_STATION_NAME}${RESET}"
    DOWNLOAD_FILE_URL="https://${SOURCE_MIRROR_STATION}/debian/ls-lR.gz"
    printf "%s\n" "${YELLOW}${DOWNLOAD_FILE_URL}${RESET}"
    aria2c --no-conf --allow-overwrite=true -o ".tmoe_netspeed_test_${SOURCE_MIRROR_STATION_NAME}_temp_file" "${DOWNLOAD_FILE_URL}"
    rm -f ".tmoe_netspeed_test_${SOURCE_MIRROR_STATION_NAME}_temp_file"
    printf "%s\n" "---------------------------"
}
################
mirror_sources_station_download_speed_test() {
    printf "%s\n" "此操作可能会消耗您${YELLOW}数十至上百兆${RESET}的${BLUE}流量${RESET}"
    do_you_want_to_continue
    cd /tmp
    printf "%s\n" "---------------------------"
    SOURCE_MIRROR_STATION_NAME='清华镜像站'
    SOURCE_MIRROR_STATION='mirrors.tuna.tsinghua.edu.cn'
    download_debian_ls_lr
    SOURCE_MIRROR_STATION_NAME='中科大镜像站'
    SOURCE_MIRROR_STATION='mirrors.ustc.edu.cn'
    download_debian_ls_lr
    SOURCE_MIRROR_STATION_NAME='上海交大镜像站'
    SOURCE_MIRROR_STATION='mirror.sjtu.edu.cn'
    download_debian_ls_lr
    SOURCE_MIRROR_STATION_NAME='北外镜像站'
    SOURCE_MIRROR_STATION='mirrors.bfsu.edu.cn'
    download_debian_ls_lr
    SOURCE_MIRROR_STATION_NAME='华为云镜像站'
    SOURCE_MIRROR_STATION='mirrors.huaweicloud.com'
    download_debian_ls_lr
    SOURCE_MIRROR_STATION_NAME='阿里云镜像站'
    SOURCE_MIRROR_STATION='mirrors.aliyun.com'
    download_debian_ls_lr
    SOURCE_MIRROR_STATION_NAME='网易镜像站'
    SOURCE_MIRROR_STATION='mirrors.163.com'
    download_debian_ls_lr
    ###此处一定要将SOURCE_MIRROR_STATION赋值为空
    SOURCE_MIRROR_STATION=""
    rm -f .tmoe_netspeed_test_*_temp_file
    printf "%s\n" "测试${YELLOW}完成${RESET}，已自动${RED}清除${RESET}${BLUE}临时文件。${RESET}"
    printf "%s\n" "下载${GREEN}速度快${RESET}并不意味着${BLUE}更新频率高。${RESET}"
    printf "%s\n" "请${YELLOW}自行${RESET}${BLUE}选择${RESET}"
}
######################
ping_mirror_sources_list_count_3() {
    printf "%s\n" "${YELLOW}${SOURCE_MIRROR_STATION}${RESET}"
    printf "%s\n" "${BLUE}${SOURCE_MIRROR_STATION_NAME}${RESET}"
    ping -c 3 ${SOURCE_MIRROR_STATION} | egrep 'avg|time.*ms' --color=auto
    printf "%s\n" "---------------------------"
}
##############
ping_mirror_sources_list() {
    printf "%s\n" "时间越短，延迟越低"
    printf "%s\n" "---------------------------"
    SOURCE_MIRROR_STATION_NAME='清华镜像站'
    SOURCE_MIRROR_STATION='mirrors.tuna.tsinghua.edu.cn'
    ping_mirror_sources_list_count_3
    SOURCE_MIRROR_STATION_NAME='中科大镜像站'
    SOURCE_MIRROR_STATION='mirrors.ustc.edu.cn'
    ping_mirror_sources_list_count_3
    SOURCE_MIRROR_STATION_NAME='上海交大镜像站'
    SOURCE_MIRROR_STATION='mirror.sjtu.edu.cn'
    ping_mirror_sources_list_count_3
    SOURCE_MIRROR_STATION_NAME='华为云镜像站'
    SOURCE_MIRROR_STATION='mirrors.huaweicloud.com'
    ping_mirror_sources_list_count_3
    SOURCE_MIRROR_STATION_NAME='阿里云镜像站'
    SOURCE_MIRROR_STATION='mirrors.aliyun.com'
    ping_mirror_sources_list_count_3
    SOURCE_MIRROR_STATION_NAME='网易镜像站'
    SOURCE_MIRROR_STATION='mirrors.163.com'
    ping_mirror_sources_list_count_3
    ###此处一定要将SOURCE_MIRROR_STATION赋值为空
    SOURCE_MIRROR_STATION=""
    printf "%s\n" "测试${YELLOW}完成${RESET}"
    printf "%s\n" "延迟${GREEN}时间低${RESET}并不意味着${BLUE}下载速度快。${RESET}"
    printf "%s\n" "请${YELLOW}自行${RESET}${BLUE}选择${RESET}"
}
##############
modify_kali_mirror_sources_list() {
    printf "%s\n" "检测到您使用的是Kali系统"
    sed -i 's/^deb/# &/g' /etc/apt/sources.list
    cat >>/etc/apt/sources.list <<-EndOfSourcesList
		deb http://${SOURCE_MIRROR_STATION}/kali/ kali-rolling main contrib non-free
		deb http://${SOURCE_MIRROR_STATION}/debian/ stable main contrib non-free
		# deb http://${SOURCE_MIRROR_STATION}/kali/ kali-last-snapshot main contrib non-free
	EndOfSourcesList
    case ${SOURCE_MIRROR_STATION} in
    "http.kali.org") sed -i "s@http.kali.org/debian@deb.debian.org/debian@g" /etc/apt/sources.list ;;
    esac
    #注意：kali-rolling添加debian testing源后，可能会破坏系统依赖关系，可以添加stable源（暂未发现严重影响）
}
#############
check_ca_certificates_and_apt_update() {
    if [ "${DEBIAN_SECURITY_SOURCE}" != "true" ]; then
        if [ -e "/usr/sbin/update-ca-certificates" ]; then
            printf "%s\n" "检测到您已安装ca-certificates"
            printf "%s\n" "Replacing http software source list with https."
            printf "%s\n" "正在将http源替换为https..."
            #update-ca-certificates
            sed -i 's@http:@https:@g' /etc/apt/sources.list
            sed -i 's@https://security@http://security@g' /etc/apt/sources.list
        fi
    fi
    apt update
    apt dist-upgrade
    printf "%s\n" "修改完成，您当前的${BLUE}软件源列表${RESET}如下所示。"
    sed -n p /etc/apt/sources.list
    sed -n p /etc/apt/sources.list.d/* 2>/dev/null
    printf "%s\n" "您可以输${YELLOW}apt edit-sources${RESET}来手动编辑软件源列表"
}
#############
modify_ubuntu_mirror_sources_list() {
    if grep -q 'Bionic Beaver' "/etc/os-release"; then
        SOURCELISTCODE='bionic'
        printf '%s\n' '18.04 LTS'
    elif grep -q 'Focal Fossa' "/etc/os-release"; then
        SOURCELISTCODE='focal'
        printf '%s\n' '20.04 LTS'
    elif grep -q 'Xenial' "/etc/os-release"; then
        SOURCELISTCODE='xenial'
        printf '%s\n' '16.04 LTS'
    elif grep -q 'Cosmic' "/etc/os-release"; then
        SOURCELISTCODE='cosmic'
        printf '%s\n' '18.10'
    elif grep -q 'Disco' "/etc/os-release"; then
        SOURCELISTCODE='disco'
        printf '%s\n' '19.04'
    elif grep -q 'Eoan' "/etc/os-release"; then
        SOURCELISTCODE='eoan'
        printf '%s\n' '19.10'
    else
        SOURCELISTCODE=$(sed -n p /etc/os-release | grep VERSION_CODENAME | cut -d '=' -f 2 | head -n 1)
        printf "%s\n" "$(sed -n p /etc/os-release | grep PRETTY_NAME | cut -d '=' -f 2 | cut -d '"' -f 2 | head -n 1)"
    fi
    printf "%s\n" "检测到您使用的是Ubuntu ${SOURCELISTCODE}系统"
    sed -i 's/^deb/# &/g' /etc/apt/sources.list
    #下面那行EndOfSourcesList不能有单引号
    cat >>/etc/apt/sources.list <<-EndOfSourcesList
		deb http://${SOURCE_MIRROR_STATION}/ubuntu/ ${SOURCELISTCODE} main restricted universe multiverse
		deb http://${SOURCE_MIRROR_STATION}/ubuntu/ ${SOURCELISTCODE}-updates main restricted universe multiverse
		deb http://${SOURCE_MIRROR_STATION}/ubuntu/ ${SOURCELISTCODE}-backports main restricted universe multiverse
		deb http://${SOURCE_MIRROR_STATION}/ubuntu/ ${SOURCELISTCODE}-security main restricted universe multiverse
		# proposed为预发布软件源，不建议启用
		# deb https://${SOURCE_MIRROR_STATION}/ubuntu/ ${SOURCELISTCODE}-proposed main restricted universe multiverse
	EndOfSourcesList
    case "${ARCH_TYPE}" in
    amd64 | i386) ;;
    *) sed -i 's:/ubuntu:/ubuntu-ports:g' /etc/apt/sources.list ;;
    esac
}
#############
modify_debian_mirror_sources_list() {
    NEW_DEBIAN_SOURCES_LIST='false'
    if grep -q '^PRETTY_NAME.*sid' "/etc/os-release"; then
        if [ "$(lsb_release -r | awk '{print $2}' | awk -F '/' '{print $1}')" = 'testing' ]; then
            if (whiptail --title "DEBIAN VERSION" --yes-button "testing" --no-button "sid" --yesno "Are you using debian testing or sid?\n汝今方用何本？♪(^∇^*) " 0 0); then
                NEW_DEBIAN_SOURCES_LIST='true'
                SOURCELISTCODE='testing'
                BACKPORTCODE=$(sed -n p /etc/os-release | grep PRETTY_NAME | head -n 1 | cut -d '=' -f 2 | cut -d '"' -f 2 | awk -F ' ' '$0=$NF' | cut -d '/' -f 1)
            else
                SOURCELISTCODE='sid'
            fi
        else
            SOURCELISTCODE='sid'
        fi

    elif ! egrep -q 'buster|stretch|jessie' "/etc/os-release"; then
        NEW_DEBIAN_SOURCES_LIST='true'
        if grep -q 'VERSION_CODENAME' "/etc/os-release"; then
            SOURCELISTCODE=$(sed -n p /etc/os-release | grep VERSION_CODENAME | cut -d '=' -f 2 | head -n 1)
        else
            printf "%s\n" "不支持您的系统！"
            press_enter_to_return
            tmoe_sources_list_manager
        fi
        BACKPORTCODE=${SOURCELISTCODE}

    elif grep -q 'buster' "/etc/os-release"; then
        SOURCELISTCODE='buster'
        BACKPORTCODE='buster'
        #printf "%s\n" "Debian 10 buster"

    elif grep -q 'stretch' "/etc/os-release"; then
        SOURCELISTCODE='stretch'
        BACKPORTCODE='stretch'
        #printf "%s\n" "Debian 9 stretch"

    elif grep -q 'jessie' "/etc/os-release"; then
        SOURCELISTCODE='jessie'
        BACKPORTCODE='jessie'
        #printf "%s\n" "Debian 8 jessie"
    fi
    printf "%s\n" "$(sed -n p /etc/os-release | grep PRETTY_NAME | cut -d '=' -f 2 | cut -d '"' -f 2 | head -n 1)"
    printf "%s\n" "检测到您使用的是Debian ${SOURCELISTCODE}系统"
    sed -i 's/^deb/# &/g' /etc/apt/sources.list
    if [ "${SOURCELISTCODE}" = "sid" ]; then
        cat >>/etc/apt/sources.list <<-EndOfSourcesList
			deb http://${SOURCE_MIRROR_STATION}/debian/ sid main contrib non-free
			#deb http://${SOURCE_MIRROR_STATION}/debian/ experimental main contrib non-free
		EndOfSourcesList
    else
        if [ "${NEW_DEBIAN_SOURCES_LIST}" = "true" ]; then
            cat >>/etc/apt/sources.list <<-EndOfSourcesList
				deb http://${SOURCE_MIRROR_STATION}/debian/ ${SOURCELISTCODE} main contrib non-free
				deb http://${SOURCE_MIRROR_STATION}/debian/ ${SOURCELISTCODE}-updates main contrib non-free
				deb http://${SOURCE_MIRROR_STATION}/debian/ ${BACKPORTCODE}-backports main contrib non-free
				deb http://${SOURCE_MIRROR_STATION}/debian-security/ ${SOURCELISTCODE}-security main contrib non-free
			EndOfSourcesList
            if [ "${DEBIAN_SECURITY_SOURCE}" = "true" ]; then
                sed -i 's@^deb.*debian-security@#&@' /etc/apt/sources.list
                cat >>/etc/apt/sources.list <<-EndOfsecuritySource
					deb http://security.debian.org/debian-security/ ${SOURCELISTCODE}-security main contrib non-free
				EndOfsecuritySource
            fi
        else
            #下面那行EndOfSourcesList不能加单引号
            cat >>/etc/apt/sources.list <<-EndOfSourcesList
				deb http://${SOURCE_MIRROR_STATION}/debian/ ${SOURCELISTCODE} main contrib non-free
				deb http://${SOURCE_MIRROR_STATION}/debian/ ${SOURCELISTCODE}-updates main contrib non-free
				deb http://${SOURCE_MIRROR_STATION}/debian/ ${BACKPORTCODE}-backports main contrib non-free
				deb http://${SOURCE_MIRROR_STATION}/debian-security/ ${SOURCELISTCODE}/updates main contrib non-free
			EndOfSourcesList
            if [ "${DEBIAN_SECURITY_SOURCE}" = "true" ]; then
                sed -i 's@^deb.*debian-security@#&@' /etc/apt/sources.list
                cat >>/etc/apt/sources.list <<-EndOfsecuritySource
					deb http://security.debian.org/debian-security/ ${SOURCELISTCODE}/updates main contrib non-free
				EndOfsecuritySource
            fi
        fi
    fi
}
##############
restore_normal_default_sources_list() {
    if [ -e "${SOURCES_LIST_BACKUP_FILE}" ]; then
        cd ${SOURCES_LIST_PATH}
        cp -pvf ${SOURCES_LIST_FILE_NAME} ${SOURCES_LIST_BACKUP_FILE_NAME}
        cp -pf ${SOURCES_LIST_BACKUP_FILE} ${SOURCES_LIST_FILE}
        ${TMOE_UPDATE_COMMAND}
        printf "%s\n" "您当前的软件源列表已经备份至${YELLOW}$(pwd)/${SOURCES_LIST_BACKUP_FILE_NAME}${RESET}"
        diff ${SOURCES_LIST_BACKUP_FILE_NAME} ${SOURCES_LIST_FILE_NAME} -y --color
        printf "%s\n" "${YELLOW}左侧${RESET}显示的是${RED}旧源${RESET}，${YELLOW}右侧${RESET}为${GREEN}当前的${RESET}${BLUE}软件源${RESET}"
    else
        printf "%s\n" "检测到备份文件不存在，还原失败。"
    fi
    ###################
    if [ "${LINUX_DISTRO}" = "arch" ]; then
        if [ -e "${SOURCES_LIST_BACKUP_FILE_02}" ]; then
            cp -pf "${SOURCES_LIST_BACKUP_FILE_02}" "${SOURCES_LIST_FILE_02}"
        fi
    fi
}
########
restore_default_sources_list() {
    if [ ! $(command -v diff) ]; then

        DEPENDENCY_01=""
        DEPENDENCY_02="diffutils"
        beta_features_quick_install
    fi

    if [ "${LINUX_DISTRO}" = "redhat" ]; then
        tar -Ppzxvf ${SOURCES_LIST_BACKUP_FILE}
    else
        restore_normal_default_sources_list
    fi
}
#############
fedora_31_repos() {
    curl -o /etc/yum.repos.d/fedora.repo http://${SOURCE_MIRROR_STATION}/repo/fedora.repo
    curl -o /etc/yum.repos.d/fedora-updates.repo http://${SOURCE_MIRROR_STATION}/repo/fedora-updates.repo
}
###########
#fedora-bfsu:SOURCE_MIRROR_STATION=mirrors.bfsu.edu.cn
fedora_32_repos() {
    cat >/etc/yum.repos.d/fedora.repo <<-EndOfYumRepo
		[fedora]
		name=Fedora \$releasever - \$basearch
		failovermethod=priority
		baseurl=https://${SOURCE_MIRROR_STATION}/fedora/releases/\$releasever/Everything/\$basearch/os/
		metadata_expire=28d
		gpgcheck=1
		gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-fedora-\$releasever-\$basearch
		skip_if_unavailable=False
	EndOfYumRepo

    cat >/etc/yum.repos.d/fedora-updates.repo <<-EndOfYumRepo
		[updates]
		name=Fedora \$releasever - \$basearch - Updates
		failovermethod=priority
		baseurl=https://${SOURCE_MIRROR_STATION}/fedora/updates/\$releasever/Everything/\$basearch/
		enabled=1
		gpgcheck=1
		metadata_expire=6h
		gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-fedora-\$releasever-\$basearch
		skip_if_unavailable=False
	EndOfYumRepo
}
#########################
fedora_3x_repos() {
    cat >/etc/yum.repos.d/fedora-modular.repo <<-EndOfYumRepo
		[fedora-modular]
		name=Fedora Modular \$releasever - \$basearch
		failovermethod=priority
		baseurl=https://${SOURCE_MIRROR_STATION}/fedora/releases/\$releasever/Modular/\$basearch/os/
		enabled=1
		metadata_expire=7d
		gpgcheck=1
		gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-fedora-\$releasever-\$basearch
		skip_if_unavailable=False
	EndOfYumRepo

    cat >/etc/yum.repos.d/fedora-updates-modular.repo <<-EndOfYumRepo
		[updates-modular]
		name=Fedora Modular \$releasever - \$basearch - Updates
		failovermethod=priority
		baseurl=https://${SOURCE_MIRROR_STATION}/fedora/updates/\$releasever/Modular/\$basearch/
		enabled=1
		gpgcheck=1
		metadata_expire=6h
		gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-fedora-\$releasever-\$basearch
		skip_if_unavailable=False
	EndOfYumRepo
}
###############
modify_to_kali_sources_list() {
    case "${LINUX_DISTRO}" in
    "debian")
        case "${DEBIAN_DISTRO}" in
        "ubuntu")
            printf "%s\n" "${YELLOW}非常抱歉，暂不支持Ubuntu，按回车键返回。${RESET}"
            printf "%s\n" "Press ${GREEN}enter${RESET} to ${BLUE}return.${RESET}"
            read
            tmoe_linux_tool_menu
            ;;
        esac
        ;;
    *)
        printf "%s\n" "${YELLOW}非常抱歉，检测到您使用的不是deb系linux，按回车键返回。${RESET}"
        printf "%s\n" "Press ${GREEN}enter${RESET} to ${BLUE}return.${RESET}"
        read
        tmoe_linux_tool_menu
        ;;
    esac

    if ! grep -q "^deb.*kali" /etc/apt/sources.list; then
        printf "%s\n" "检测到您当前为debian源，是否修改为kali源？"
        printf "%s\n" "Detected that your current software sources list is debian, do you need to modify it to kali source?"
        RETURN_TO_WHERE='tmoe_linux_tool_menu'
        do_you_want_to_continue
        kali_sources_list
    else
        printf "%s\n" "检测到您当前为kali源，是否修改为debian源？"
        printf "%s\n" "Detected that your current software sources list is kali, do you need to modify it to debian source?"
        RETURN_TO_WHERE='tmoe_linux_tool_menu'
        do_you_want_to_continue
        debian_sources_list
    fi
}
################################
kali_sources_list() {
    if [ ! -e "/usr/bin/gpg" ]; then
        apt update
        apt install gpg -y
    fi
    #添加公钥
    apt-key adv --keyserver keyserver.ubuntu.com --recv ED444FF07D8D0BF6
    cd /etc/apt/
    cp -f sources.list sources.list.bak

    sed -i 's/^deb/#&/g' /etc/apt/sources.list
    cat >>/etc/apt/sources.list <<-'EOF'
		deb http://mirrors.bfsu.edu.cn/kali/ kali-rolling main contrib non-free
		deb http://mirrors.bfsu.edu.cn/debian/ stable main contrib non-free
		# deb https://mirrors.ustc.edu.cn/kali kali-rolling main non-free contrib
		# deb http://mirrors.bfsu.edu.cn/kali/ kali-last-snapshot main contrib non-free
	EOF
    apt update
    apt list --upgradable
    apt full-upgrade -y
    apt install -y kali-menu
    apt search kali-linux
    printf '%s\n' 'You have successfully replaced your debian source with a kali source.'
    printf "%s\n" "Press ${GREEN}enter${RESET} to ${BLUE}return.${RESET}"
    printf "%s\n" "按${GREEN}回车键${RESET}${BLUE}返回${RESET}"
    read
    tmoe_linux_tool_menu
}
#######################
debian_sources_list() {
    sed -i 's/^deb/#&/g' /etc/apt/sources.list
    cat >>/etc/apt/sources.list <<-'EOF'
		deb https://mirrors.bfsu.edu.cn/debian/ sid main contrib non-free
	EOF
    apt update
    apt list --upgradable
    printf '%s\n' '您已换回debian源'
    apt dist-upgrade -y
    printf "%s\n" "Press ${GREEN}enter${RESET} to ${BLUE}return.${RESET}"
    printf "%s\n" "按${GREEN}回车键${RESET}${BLUE}返回${RESET}"
    read
    tmoe_linux_tool_menu
}
############################################
mirror_main "$@"
