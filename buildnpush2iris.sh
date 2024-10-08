#!/bin/bash

# Display help
Help() {
    # Display Help
    echo "This script builds the DFIR-IRIS module of the current directory and installs it to DFIR-IRIS. If you run it for the first time or change something in the module configuration template make sure to run the -a switch."
    echo
    echo "Syntax: ./buildnpush2iris [-a|h]"
    echo "options:"
    echo "a     Also install the module to the iris-web_app_1 container. Only required on initial install or when changes to config template were made."
    echo "h     Print this Help."
    echo
}

Run() {
    echo "[BUILDnPUSH2IRIS] Starting the build and push process.."

    .venv/bin/python3.9 setup.py bdist_wheel > /dev/null

    latest=$(find dist -type f -name '*.whl' | sort -n | tail -1)
    module=$(basename "$latest")

    echo "[BUILDnPUSH2IRIS] Found latest module file: $latest"
    echo "[BUILDnPUSH2IRIS] Copy module file to worker container.."
    docker cp "$latest" iriswebapp_worker:/iriswebapp/dependencies/
    echo "[BUILDnPUSH2IRIS] Installing module in worker container.."

    docker exec -it iriswebapp_worker /bin/sh -c "python -m pip install -U pip"
    docker exec -it iriswebapp_worker /bin/sh -c "python -m pip install /iriswebapp/dependencies/$module --force-reinstall"
    echo "[BUILDnPUSH2IRIS] Restarting worker container.."
    docker restart iriswebapp_worker

    if [ "$a_Flag" = true ] ; then
        echo "[BUILDnPUSH2IRIS] Copy module file to app container.."
        docker cp "$latest" iriswebapp_app:/iriswebapp/dependencies/
        echo "[BUILDnPUSH2IRIS] Installing module in app container.."
        docker exec -it iriswebapp_app /bin/sh -c "python -m pip install -U pip"
        docker exec -it iriswebapp_app /bin/sh -c "python -m pip install /iriswebapp/dependencies/$module --force-reinstall"
        echo "[BUILDnPUSH2IRIS] Restarting app container.."
        docker restart iriswebapp_app
    fi

    echo "[BUILDnPUSH2IRIS] Completed!"
}

a_Flag=false

while getopts ":ha" option; do
    case $option in
        h) # Display help message
            Help
            exit;;
        a) # Install module to worker and app container
             echo "[BUILDnPUSH2IRIS] Pushing to Worker and App container!"
            a_Flag=true
            Run
            exit;;
        \?) # Invalid option
            echo "ERROR: Invalid option"
            exit;;
    esac
done

echo "[BUILDnPUSH2IRIS] Pushing to Worker container only!"
Run
exit
