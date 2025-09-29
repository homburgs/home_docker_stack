export OC_PASS=banane

php occ app:install notify_push
php occ app:install user_oidc
php occ app:install groupfolders
php occ app:install memories
php occ app:install tasks
php occ app:install mail
php occ app:install richdocuments
php occ app:install contacts
php occ app:install files_versions

php occ app:disable activity
php occ app:disable dashboard
php occ app:disable federation
php occ app:disable cfg_share_links
php occ app:disable cloud_federation_api
php occ app:disable federatedfilesharing
php occ app:disable firstrunwizard
php occ app:disable survey_client
php occ app:disable support
php occ app:disable privacy
php occ app:disable files_sharing
php occ app:disable oauth2
php occ app:enable files_external

php occ config:system:set enabledPreviewProviders 0 --value 'OC\Preview\MP3'
php occ config:system:set enabledPreviewProviders 1 --value 'OC\Preview\TXT'
php occ config:system:set enabledPreviewProviders 2 --value 'OC\Preview\MarkDown'
php occ config:system:set enabledPreviewProviders 3 --value 'OC\Preview\OpenDocument'
php occ config:system:set enabledPreviewProviders 4 --value 'OC\Preview\Krita'
php occ config:system:set enabledPreviewProviders 5 --value 'OC\Preview\Imaginary'
php occ config:system:set preview_imaginary_url --value 'http://nextcloud_imaginary:9000'
# limit number of parallel jobs (adopt to your CPU core number)
php occ config:system:set preview_concurrency_all --value 12
php occ config:system:set preview_concurrency_new --value 8
php occ config:system:set preview_concurrency_new --value 8

php occ config:system:set default_language --value 'de'
php occ config:system:set default_local --value 'de_DE'
php occ config:system:set default_phone_region --value 'DE'
php occ config:system:set maintenance_window_start --type=integer --value=1
php occ notify_push:metrics
php occ notify_push:self-test
php occ maintenance:repair --include-expensive
php occ db:add-missing-indices
php occ config:system:set loglevel --type integer --value 2
php occ config:system:set debug --type boolean --value false
php occ config:system:set logtimezone --value="Europe/Berlin"

php occ group:add "Team Homburg"
php occ group:add "Team Test"

php occ groupfolders:create "Team Homburg"
php occ groupfolders:group 1 "Team Homburg" write delete
php occ groupfolders:create "Team Test"
php occ groupfolders:group 2 "Team Test" write delete

php occ files_external:create -c datadir=/mnt/Muellhalde "Kerstins Müllhalde" local null::null
php occ files_external:applicable --add-group "Team Homburg" 1

php occ app:disable password_policy
php occ user:add --display-name="Sven Homburg" --email="Sven.Homburg@hsofttec.com" --password-from-env --group="admin" --group="Team Homburg" --group="Team Test" shomburg
php occ user:add --display-name="Kerstin Homburg" --email="ke.homburg@gmail.com" --password-from-env --group="Team Homburg" khomburg
php occ user:add --display-name="Test Eins" --email="Sven.Homburg@hsofttec.com" --password-from-env --group="Team Test" test1
php occ app:enable password_policy

#php occ user:setting shomburg settings core lang "de"
#php occ user:setting khomburg settings core lang "de"
#php occ user:setting test1 settings core lang "de"

php occ notify_push:setup https://next.homburg.dynv6.net/push
php occ background:cron
