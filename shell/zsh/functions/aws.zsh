# awsp
alias awsp=aws_profile_update
function aws_profile_update() {
    PROFILES=$(aws configure list-profiles)
    PROFILES_ARRAY=($(echo $PROFILES))
    SELECTED_PROFILE=$(echo $PROFILES | fzf)

    [[ -n ${PROFILES_ARRAY[(re)${SELECTED_PROFILE}]} ]] && export AWS_PROFILE=${SELECTED_PROFILE}; echo 'Updated profile' || echo ''
}
