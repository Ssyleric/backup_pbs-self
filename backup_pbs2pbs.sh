#!/bin/bash

# 🔐 Auth avec API Token
export PBS_REPOSITORY="backup@pbs!pveclient2@192.168.1.101:marechal-pbs"
export PBS_PASSWORD="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

PXAR_NAME="root.pxar"
BACKUP_ID="pbs-self"
LOGFILE="/var/log/backup-pbs-self.log"

# 📤 Discord Webhook
WEBHOOK="https://discord.com/api/webhooks/xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

# 🕒 Début
START_TIME="$(date)"
echo -e "[$START_TIME]\n🔄 Starting backup of / to $PBS_REPOSITORY as $PXAR_NAME (ID: $BACKUP_ID)" > "$LOGFILE"

# 🚀 Backup
proxmox-backup-client backup "$PXAR_NAME:/" --repository "$PBS_REPOSITORY" --backup-id "$BACKUP_ID" >> "$LOGFILE" 2>&1
STATUS=$?
END_TIME="$(date)"

if [ "$STATUS" -eq 0 ]; then
    echo -e "\n[$END_TIME]\n✅ Backup completed successfully." >> "$LOGFILE"
else
    echo -e "\n[$END_TIME]\n❌ Backup failed with status $STATUS." >> "$LOGFILE"
fi

# 📦 Retention dynamique (optionnel)
RETENTION=$(proxmox-backup-client snapshot list --repository "$PBS_REPOSITORY" --backup-id "$BACKUP_ID" 2>/dev/null | grep 'keep-' | tail -n1 | tr -d ' ')
[ -n "$RETENTION" ] && echo -e "\n📌 Retention policy: $RETENTION" >> "$LOGFILE"

# 📤 Notification Discord avec log en pièce jointe
curl -F "payload_json={\"content\":\"📦 Rapport sauvegarde PBS (ID: $BACKUP_ID)\"}" \
     -F "file=@$LOGFILE;type=text/plain" \
     "$WEBHOOK"
