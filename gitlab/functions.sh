function wait_system_online() {
    while getopts ":t:h:p:" o; do
        case "${o}" in
            t)
                TIMEOUT=${OPTARG}
                ;;
            h)
                NC_HOST=${OPTARG}
                ;;
            p)
                NC_PORT=${OPTARG}
                ;;
            *)
                echo "Usage $0 [-t <timeout>] [-h <hostname>] [-p <port>]" 1>&2; exit 1;
                ;;
        esac;
    done;
    shift $((OPTIND-1));

    # Sanity check
    if [ -z "${TIMEOUT}" ] || [ -z "${NC_HOST}" ] || [ -z "${NC_PORT}" ]; then
      exit 1;
    fi;

    # Main loop
    until nc ${NC_HOST} ${NC_PORT} -w 1 || [ ${TIMEOUT} -eq 0 ];
    do
      echo "System ${NC_HOST} not yet ready, sleeping... (${TIMEOUT} attempts remaining)";
      sleep 2;
      TIMEOUT=$(( ${TIMEOUT} - 1 ));
    done;
    if [ ${TIMEOUT} -eq 0 ]; then exit 1 ; fi;
}

function wait_system_offline() {
    while getopts ":t:h:p:" o; do
        case "${o}" in
            t)
                TIMEOUT=${OPTARG}
                ;;
            h)
                NC_HOST=${OPTARG}
                ;;
            p)
                NC_PORT=${OPTARG}
                ;;
            *)
                echo "Usage $0 [-t <timeout>] [-h <hostname>] [-p <port>]" 1>&2; exit 1;
                ;;
        esac;
    done;
    shift $((OPTIND-1));

    # Sanity check
    if [ -z "${TIMEOUT}" ] || [ -z "${NC_HOST}" ] || [ -z "${NC_PORT}" ]; then
      exit 1;
    fi;

    # Main loop
    until ! nc ${NC_HOST} ${NC_PORT} -w 1 || [ ${TIMEOUT} -eq 0 ];
    do
      echo "System ${NC_HOST} not yet ready, sleeping... (${TIMEOUT} attempts remaining)";
      sleep 2;
      TIMEOUT=$(( ${TIMEOUT} - 1 ));
    done;
    if [ ${TIMEOUT} -eq 0 ]; then exit 1 ; fi;
}


function wait_libvirtd_active() {
    while getopts ":t:h:p:" o; do
        case "${o}" in
            t)
                TIMEOUT=${OPTARG}
                ;;
            h)
                HVM=${OPTARG}
                ;;
            *)
                echo "Usage $0 [-t <timeout>] [-h <hostname>] [-p <port>]" 1>&2; exit 1;
                ;;
        esac;
    done;
    shift $((OPTIND-1));

    # Sanity check
    if [ -z "${TIMEOUT}" ] || [ -z "${HVM}" ]; then
      exit 1;
    fi;

    # main loop
    until ssh -q -t ${SSH_USER}@${HVM} /usr/bin/systemctl -q is-active libvirtd || [ $TIMEOUT -eq 0 ];
    do
        echo "Libvirtd on ${HVM} not yet ready, sleeping... (${TIMEOUT} attempts remaining)";
        sleep 2;
        TIMEOUT=$(( $TIMEOUT - 1 ));
    done;
    if [ ${TIMEOUT} -eq 0 ]; then exit 1 ; fi;
}

function wait_ironic_active() {
    while getopts ":t:h:p:" o; do
        case "${o}" in
            t)
                TIMEOUT=${OPTARG}
                ;;
            h)
                INSTACK_DNS=${OPTARG}
                ;;
            *)
                echo "Usage $0 [-t <timeout>] [-h <hostname>] [-p <port>]" 1>&2; exit 1;
                ;;
        esac;
    done;
    shift $((OPTIND-1));

    # Sanity check
    if [ -z "${TIMEOUT}" ] || [ -z "${INSTACK_DNS}" ]; then
      exit 1;
    fi;

    case $(ssh -q -t stack@${INSTACK_DNS} uname -r|cut -d- -f1) in
       3.10.0)
           mysvc="openstack-ironic-conductor"
           ;;
       4.18.0)
           mysvc="tripleo_ironic_inspector"
           ;;
       *)
           mysvc="openstack-ironic-conductor"
           ;;
    esac;
    # main loop
    until ssh -q -t stack@${INSTACK_DNS} /usr/bin/systemctl -q is-active ${mysvc} || [ $TIMEOUT -eq 0 ];
    do
        echo "${mysvc} on ${INSTACK_DNS} not yet ready, sleeping... (${TIMEOUT} attempts remaining)";
        sleep 2;
        TIMEOUT=$(( $TIMEOUT - 1 ));
    done;
    if [ ${TIMEOUT} -eq 0 ]; then exit 1 ; fi;
}
