# 📄 README – Sauvegarde Automatique de PBS vers PBS distant (`pbs-self`)

## 🎯 Objectif

Mettre en place une **sauvegarde régulière de la racine (`/`) du serveur PBS** vers un **dépôt distant** géré par un autre serveur PBS (`192.168.1.101`), en utilisant le client `proxmox-backup-client` et une authentification par **API Token**.

## 🗂️ Fichier de script

**Chemin :** `/home/scripts/backup_pbs2pbs.sh`
**But :** Sauvegarder `/` en excluant les points non pertinents (`/mnt/datastore`, `/sys`, etc.).

## 🔐 Authentification

Utilisation d’un token sécurisé :

```bash
PBS_REPOSITORY="backup@pbs!pveclient2@192.168.1.101:marechal-pbs"
PBS_PASSWORD="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
```

> Le token `pveclient2` a les droits sur le dépôt `marechal-pbs`.

## ⚙️ Commande exécutée

```bash
proxmox-backup-client backup root.pxar:/ \
  --exclude /mnt/datastore \
  --repository backup@pbs!pveclient2@192.168.1.101:marechal-pbs \
  --backup-id pbs-self
```

## 📝 Log

Toutes les exécutions sont journalisées ici :

```
/var/log/backup-pbs-self.log
```

Pour voir l’état en temps réel :

```bash
tail -f /var/log/backup-pbs-self.log
```

## 📤 Notification

Le script envoie une notification Discord avec le log complet à l'issue du backup.

## ✅ Exemple de succès

```
root.pxar: had to backup 2.65 GiB of 2.653 GiB (compressed 1021.971 MiB)
Duration: 47.01s
✅ Backup completed successfully.
```

## 🔁 Programmation (optionnelle)

Tu peux automatiser la tâche via `cron` :

```bash
0 4 * * * /home/scripts/backup_pbs2pbs.sh
```

Ou via un `systemd timer` (plus fiable sur PBS, recommandé si tu veux un service journalisé).

## 🛑 Précautions

- Ne jamais inclure `/mnt/datastore` pour éviter de sauvegarder les backups eux-mêmes.
- Le premier run demandera confirmation TLS (`Are you sure you want to continue connecting?`) : faire une exécution manuelle avant automatisation.
