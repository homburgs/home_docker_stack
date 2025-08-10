docker exec nextcloud_apps sh -c 'php occ notify_push:setup https://next.homburg.dynv6.net/push'
docker exec nextcloud_apps php occ notify_push:metrics
docker exec nextcloud_apps php occ notify_push:self-test
docker exec nextcloud_apps php occ maintenance:repair --include-expensive
docker exec nextcloud_apps php occ db:add-missing-indices
docker exec nextcloud_apps php occ mail
docker exec nextcloud_apps php occ config:system:set loglevel --type integer --value 2
docker exec nextcloud_apps php occ config:system:set debug --type boolean --value false
docker exec nextcloud_apps php occ config:system:set logtimezone --value="Europe/Berlin"
