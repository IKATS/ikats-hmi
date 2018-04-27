#! /bin/bash

# This script is launched by the docker container at boot.
# It replaces some HMI variables with environement ones
# and then give back control to nginx.

set -e


function test_for_variable {
  vname=$1
  vvalue=${!vname}
  default_value=$2

  if [ -z "$vvalue" ]
  then
    if [ -z "$2" ]
    then
      # No fallback has been given to the function
      echo "The environment variable ${vname} must have a value"
      exit 1
    else
      # Setting the variable value to the provided default
      eval $vname=$default_value
    fi
  fi
}



env_variables=(
  "GUNICORN_ADDR"
  "TOMCAT_ADDR"
  "OPENTSDB_ADDR"
  "TOMEE_ADDR"
)

for v in "${env_variables[@]}"
do
  test_for_variable $v
  # put the variable in lowercase
  # (syntax expected by the HMI configuration)
  lv=`echo $v | tr '[:upper:]' '[:lower:]'`

  echo "Endpoint for `echo $lv | cut -d '_' -f1`: ${!v}"

  # put the environment variable value in the `ikats_api.js` file
  sed -i \
    "s@ikats.constants.$lv = .*@ikats.constants.$lv = \"${!v}\";@g" \
    /usr/share/nginx/html/js/ikats_api.js
done

echo "HMI configured, starting nginx."

nginx -g "daemon off;"
