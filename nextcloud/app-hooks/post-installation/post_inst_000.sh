php occ app:install notify_push
php occ app:install user_oidc
php occ app:install groupfolders
php occ app:install memories
php occ app:install tasks
php occ app:install cfg_share_links
php occ app:install mail
php occ app:install mail
php occ app:install richdocuments
php occ app:install contacts
php occ app:install files_external
php occ app:disable activity
php occ app:disable dashboard

php occ config:system:get enabledPreviewProviders
php occ config:system:set enabledPreviewProviders 0 --value 'OC\Preview\MP3'
php occ config:system:set enabledPreviewProviders 1 --value 'OC\Preview\TXT'
php occ config:system:set enabledPreviewProviders 2 --value 'OC\Preview\MarkDown'
php occ config:system:set enabledPreviewProviders 3 --value 'OC\Preview\OpenDocument'
php occ config:system:set enabledPreviewProviders 4 --value 'OC\Preview\Krita'
php occ config:system:set enabledPreviewProviders 5 --value 'OC\Preview\Imaginary'
php occ config:system:set preview_imaginary_url --value 'http://imaginary:9000'
# limit number of parallel jobs (adopt to your CPU core number)
php occ config:system:set preview_concurrency_all --value 12
php occ config:system:set preview_concurrency_new --value 8
php occ config:system:set preview_concurrency_new --value 8

php occ config:system:set default_language --value 'de'
php occ config:system:set default_local --value 'de_DE'
php occ config:system:set default_phone_region --value 'DE'
php occ config:system:set maintenance_window_start --type=integer --value=1
php occ background:cron
