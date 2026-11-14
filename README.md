# Container-Umgebung

Dieses Repository enthält Docker-Compose-Konfigurationen für einen privaten Server. Der Haupt-Stack wird über `home-office-compose.yaml` verwaltet; AdGuard Home ist wegen seiner besonderen Netzwerk- und Portbelegung ein eigener Stack. Die Konfiguration enthält feste Host-Pfade, Netzwerkadressen und Hostnamen und ist daher nicht ohne Anpassungen auf einen anderen Rechner übertragbar.

## Enthaltene Dienste und Dateien

Der Haupt-Stack umfasst:

- **Daten und Cache:** PostgreSQL und Redis
- **Nextcloud:** PHP-FPM-Anwendung, Push-Benachrichtigungsdienst und Imaginary-Bildverarbeitung; Caddy übernimmt den Reverse Proxy
- **Weitere Anwendungen:** Collabora, Gitea, MyOffice, Paperless-ngx und Vaultwarden
- **Paperless-Unterstützung:** Gotenberg und Apache Tika

AdGuard Home wird separat durch `adguard-compose.yaml` und `adguard.sh` gestartet. Die Verzeichnisse `dovecot/` und `postfix/` enthalten Dockerfiles bzw. Konfigurationen, sind aber nicht als Dienste in den hier beschriebenen Compose-Dateien eingebunden. Auch `immich.env` ist in diesen Compose-Dateien nicht referenziert.

## Voraussetzungen

- Linux-Host mit installiertem Docker Engine und Docker-Compose-Plugin (`docker compose`)
- Das Repository unter `/opt/containers` oder Anpassung aller entsprechenden absoluten Mount-Pfade in den Compose-Dateien
- Genügend Speicherplatz und Schreibrechte für die unter `/srv` eingebundenen Datenverzeichnisse
- Für den Haupt-Stack: passende DNS-Einträge und Erreichbarkeit der in `caddy/Caddyfile` konfigurierten Hostnamen; für öffentlich erreichbare Caddy-Sites müssen die erforderlichen HTTP-/HTTPS-Verbindungen möglich sein
- Für AdGuard: die in `adguard-compose.yaml` eingetragene Host-IP muss auf dem Server vorhanden sein; sie ist vor dem Start gegebenenfalls anzupassen
- Vor dem Start prüfen, ob alle benötigten Host-Verzeichnisse, Datenbanken und Berechtigungen vorhanden sind. Insbesondere greifen mehrere Anwendungen auf PostgreSQL zu; die Compose-Datei richtet nicht automatisch die Datenbank jeder Anwendung individuell ein.

## Konfiguration und Sicherheit

### Umgebungsvariablen

Die Compose-Datei im Hauptverzeichnis liest standardmäßig `.env` für Variablenersetzungen ein. `adguard.sh` übergibt dieselbe Datei ausdrücklich als Umgebungsdatei. Prüfe mindestens die dort verwendeten Einstellungen wie `POSTGRES_DB`, `POSTGRES_USER`, `NEXTCLOUD_ADMIN_USER`, `COLLABORA_USER` und `TZ`.

Paperless-ngx lädt zusätzlich `paperless.env`. Prüfe insbesondere die Einstellungen für URL, Zeitzone, OCR-Sprache und UID/GID-Mapping. Die Werte gehören zur lokalen Installation und sollten nicht ungeprüft übernommen oder veröffentlicht werden.

### Secrets

Die Haupt-Compose-Datei erwartet folgende Secret-Dateien:

| Compose-Secret | Datei |
| --- | --- |
| `postgres_password` | `secrets/postgres_password.txt` |
| `nextcloud_admin_password` | derzeit ebenfalls `secrets/postgres_password.txt` |
| `gitea_db_password` | `secrets/gitea_db_password.txt` |
| `collabora_password` | `secrets/collabora_password.txt` |
| `bitwarden_admin_token` | `secrets/bitwarden_admin_token.txt` |

Die gemeinsame Datei für PostgreSQL und das Nextcloud-Administratorkennwort ist in der Compose-Konfiguration ausdrücklich so eingetragen. Prüfe, ob das beabsichtigt ist; bei getrennten Kennwörtern muss die Secret-Zuordnung angepasst werden. Secret-Inhalte nicht in diese README, in Versionskontrolle oder in Logs kopieren und Dateien nur für berechtigte Benutzer lesbar halten.

**Vor einem Betrieb besonders prüfen:** In `home-office-compose.yaml` sind für Paperless-ngx ein Datenbankkennwort und ein Anwendungsschlüssel direkt in der Konfiguration hinterlegt. Diese Werte vor einem Einsatz durch eine geeignete Secret-Verwaltung ersetzen; falls es echte oder bereits verwendete Zugangsdaten sind, rotieren. Vaultwarden ist außerdem so konfiguriert, dass Registrierungen erlaubt sind und Debug-Logging aktiviert ist. Vor einer Erreichbarkeit aus dem Internet diese Einstellungen und alle veröffentlichten Ports überprüfen.

`.gitignore` schließt `secrets/*.txt` aus, jedoch nicht ausdrücklich `.env` oder `paperless.env`. Prüfe vor jedem Commit, dass dort keine Zugangsdaten oder andere vertrauliche Werte eingecheckt werden.

## Haupt-Stack starten

1. `.env`, `paperless.env` und die oben genannten Secret-Dateien sicher und passend zur eigenen Installation vorbereiten.
2. Feste Host-Pfade, Hostnamen, DNS-/Proxy-Einstellungen und Ports in `home-office-compose.yaml`, `caddy/Caddyfile` und `caddy/nextcloud.remote` prüfen. Caddy enthält auch Routen zu Zielen, die nicht als aktive Dienste in `home-office-compose.yaml` definiert sind; diese müssen extern erreichbar sein oder angepasst bzw. entfernt werden.
3. Das Nextcloud-Image lokal bauen. Compose referenziert `nextcloud:latest-fpm-hsofttec`, enthält aber keinen `build:`-Abschnitt:

   ```bash
   docker build -t nextcloud:latest-fpm-hsofttec ./nextcloud
   ```

4. Konfiguration validieren und den Stack starten:

   ```bash
   docker compose config -q
   docker compose up -d
   docker compose ps
   ```

Protokolle eines Dienstes anzeigen, zum Beispiel:

```bash
docker compose logs -f --tail=100 nextcloud_apps
```

## AdGuard Home verwalten

Das Skript verwendet `adguard-compose.yaml`, das Projekt `.env` und den Compose-Projektnamen `adguard`. Befehle aus dem Projektverzeichnis:

```bash
bash ./adguard.sh status
bash ./adguard.sh up
bash ./adguard.sh logs
bash ./adguard.sh restart
bash ./adguard.sh down
bash ./adguard.sh --help
```

Ohne Argument startet das Skript AdGuard Home. `down` entfernt den Container, nicht die unter `/srv/adguard/` eingebundenen Host-Daten. Die Ports für DNS, DHCP, Weboberfläche und verschlüsselte DNS-Protokolle sind in `adguard-compose.yaml` festgelegt. Sie sind an eine konkrete Host-IP gebunden und müssen mit dem lokalen Netzwerk sowie der Firewall abgestimmt werden.

## Host-Pfade und veröffentlichte Ports

Die Konfiguration bindet Daten unter anderem aus `/srv/postgres/`, `/srv/nextcloud/`, `/srv/caddy/`, `/srv/gitea/`, `/srv/paperless/`, `/srv/vaultwarden/` und `/srv/adguard/` ein. Nextcloud verwendet zusätzlich `/mnt/kerstin`; Caddy mountet Konfigurationsdateien aus `/opt/containers/caddy/`. Vor dem Start sicherstellen, dass diese Pfade auf die gewünschten Speicherorte zeigen und die Container darauf zugreifen dürfen.

Der Haupt-Stack veröffentlicht unter anderem die Host-Ports `80`, `443`, `5432`, `9980`, `3000`, `2222`, `8080` und `8000`. Die Einträge ohne explizite Bind-Adresse können auf allen Host-Netzwerkschnittstellen erreichbar sein. Nur benötigte Dienste freigeben, Zugriff per Firewall einschränken und insbesondere PostgreSQL nicht unbeabsichtigt öffentlich erreichbar machen. Die AdGuard-Portbindungen sind separat definiert.

## Betrieb und Datensicherung

- Status und Protokolle: `docker compose ps` und `docker compose logs -f --tail=100 <dienst>`
- Einzelnen Dienst neu starten: `docker compose restart <dienst>`
- Haupt-Stack anhalten und Container entfernen: `docker compose down`
- Vor Updates und Änderungen Datenbank, Anwendungsdaten, Konfigurationen und benötigte Secret-Dateien sichern. Die Compose-Datei enthält keine vollständige automatische Backup-Lösung.
- Bei einer Wiederherstellung Datenbank und dazugehörige Anwendungsdateien konsistent zusammen zurückspielen.
- `docker compose down` nicht mit `-v` ausführen, sofern das Entfernen benannter Volumes nicht ausdrücklich beabsichtigt ist. Keine Datenverzeichnisse löschen, bevor ein geprüftes Backup vorliegt.
