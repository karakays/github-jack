# Inputs validation functions


################################################################################
# Validates the position input
# Globals:
#   POSITION
# Arguments:
#   None
# Returns:
#   1 if invalid
################################################################################
validation::validate_position() {
  if ! date --date "${POSITION}" &> /dev/null \
     && [[ "${POSITION}" != 'left' ]] \
     && [[ "${POSITION}" != 'center' ]] \
     && [[ "${POSITION}" != 'right' ]]; then
    general::error 'Invalid position date or identifier'
  fi
}


################################################################################
# Validates the Github username input
# Globals:
#   GITHUB_USERNAME
# Arguments:
#   None
# Returns:
#   1 if invalid
################################################################################
validation::validate_github_username() {
  # Check that the username provided exists and is linked to an user account
  if [[ -n "${GITHUB_USERNAME}" ]] \
     && ! curl --silent "https://api.github.com/users/${GITHUB_USERNAME}" \
            | grep --quiet '"type": "User"'; then
    general::error 'Invalid Github username: non existing user profile'
  fi
}


################################################################################
# Validates the shade multiplier input
# Globals:
#   SHADE_MULTIPLIER
# Arguments:
#   None
# Returns:
#   1 if invalid
################################################################################
validation::validate_shade_multiplier() {
  if ! [[ ${SHADE_MULTIPLIER} =~ ^[1-9][0-9]* ]]; then
    general::error 'Invalid shade multiplier: non strictly positive integer'
  fi
}


################################################################################
# Validates the template input
# Globals:
#   SCRIPT_DIR
#   TEMPLATE
# Arguments:
#   None
# Returns:
#   1 if invalid
################################################################################
validation::validate_template() {
  if [[ ! -f "${TEMPLATE}" ]]; then
    local provided_template="${SCRIPT_DIR}/templates/${TEMPLATE}"

    if [[ -f "${provided_template}" ]]; then
      TEMPLATE="${provided_template}"
    else
      local error_message='non existing file or invalid identifier'
      general::error "Invalid template value: ${error_message}"
    fi
  fi

  if [[ $( tr --delete 01234'\n' < "${TEMPLATE}" | wc --chars ) != 0 ]]; then
    local error_message='should contain only integers 0 to 4 and newlines'
    general::error "Invalid template: ${error_message}"
  fi

  # Ignore trailing newlines for further checks
  local trimmed_template=$(
    sed -e :a -e '/^\n*$/{$d;N;ba' -e '}' "${TEMPLATE}"
  )

  if [[ $( echo "${trimmed_template}" | wc --lines ) != 7 ]]; then
    general::error 'Invalid template: should have 7 lines'
  fi

  local max_line_length=$( wc --max-line-length < "${TEMPLATE}" )
  local line_length

  while read line; do
    line_length=${#line}

    if [[ "${line_length}" == 0 ]]; then
      general::error 'Invalid template: empty lines are not allowed'
    fi

    if [[ "${line_length}" != "${max_line_length}" ]]; then
      general::error 'Invalid template: all lines should have the same length'
    fi
  done < <( echo "${trimmed_template}" )
}
