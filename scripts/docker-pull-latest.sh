#!/usr/bin/env bash

updated_count=0
total_count=0

for compose_file in /docker/00-docker_compose/*.yml; do
  [[ -e "$compose_file" ]] || continue
  ((total_count++))

  # Get images used by this compose file
  images_before=$(docker compose -f "$compose_file" config \
    | awk '/image:/ {print $2}' \
    | xargs -r docker image inspect --format '{{.Id}}' 2>/dev/null)

  docker compose -f "$compose_file" pull >/dev/null 2>&1

  images_after=$(docker compose -f "$compose_file" config \
    | awk '/image:/ {print $2}' \
    | xargs -r docker image inspect --format '{{.Id}}' 2>/dev/null)

  if [[ "$images_before" != "$images_after" ]]; then
    ((updated_count++))
  fi
done

wall "===== Docker Pull Latest Image ===== 

Summary: $updated_count out of $total_count stacks had updates. 

Event: Triggers after 10 minutes after boot 
Service Name: \"delicate-docker-pull-latest\" 
Service Description: \"Pull latest docker images from compose files\" 

==================================== 
Note 1: No containers were restarted automatically. Run 
	'docker compose down && docker compose up -d' 
	for services you want to refresh. 

Note 2: To view full detail of the service log, run 
	'journalctl -u delicate-docker-pull-latest.service' 

===================================="

#updated_count=0
#total_count=0

#for compose_file in /docker/00-docker_compose/*.yml; do
#  if [[ -e "$compose_file" ]]; then
#    ((total_count++))
#
#    # Capture output of pull
#    docker compose -f "$compose_file" pull 2>&1
#
#    # Detect actual update
#    if echo "$output" | grep -q "Downloaded newer image"; then
#      ((updated_count++))
#    fi
#   fi
#done

#for image in /docker/00-docker_compose/*.yml; do
#  if [[ -e "$image" ]]; then
#    docker compose -f "$image" pull 
#  fi
#done

#wall "===== Docker Pull Latest Image =====

##Summary: $updated_count out of $total_count stacks had updates.
##
##Event: Triggers after 10 minutes after boot
##Service Name: \"delicate-docker-pull-latest\"
##Service Description: \"Pull latest docker images from compose files\"
##
#====================================
#
#Note 1: No containers were restarted automatically.
#        Run 'docker compose down && docker compose up -d' for 
#        services you want to refresh.
#
#Note 2: To view full detail of the service log, run 
#        'journalctl -u delicate-docker-pull-latest.service'
#
#===================================="
