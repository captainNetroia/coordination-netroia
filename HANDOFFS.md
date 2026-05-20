# HANDOFFS.md — Transferts inter-sessions NetroIA

> Ce fichier liste les contrats de livraison entre sessions.
> Chaque handoff = une session qui doit livrer quelque chose à une autre.
> Format : [OUVERT] → en attente | [LIVRÉ] → terminé | [VALIDÉ] → testé bout-en-bout

---

## Handoffs actifs

---

### HANDOFF-001 — n8n retourne 200 propre au formulaire site

**Date ouverture** : 2026-05-06
**Statut** : [OUVERT — ROOT CAUSE IDENTIFIÉE, FIX EN ATTENTE]
**Mis à jour** : 2026-05-21 — Orchestrateur NetroIA

**Émetteur** (qui doit livrer) : session `netro-automations`
**Récepteur** (qui attend) : session `site-netroia-tech`

**Contrat** :
> La session netro-automations doit repositionner le nœud "Respond to Webhook"
> AVANT le pipeline IA dans le workflow "NetroIA - CRM Formulaire Contact".
> Architecture cible : Webhook → Validation → **Respond 200** → [Classification IA → Email → Slack → Sheets]
> → n8n répond en <2s au lieu de ~13s → bien sous le timeout AbortController 10s du formulaire

**Root cause confirmée** :
- n8n pipeline complet prend ~13 secondes (IA + Email + Slack + Sheets)
- formulaire index.html ligne 1714 : `AbortController.abort()` après 10 secondes
- 13s > 10s → ERR_ABORTED côté Chrome → catch silencieux
- CORS : ✅ OK. Nginx : ✅ OK. TLS : ✅ pas le problème.

**Critère de validation finale** :
- Soumettre le formulaire sur https://netroia.tech depuis Chrome
- La réponse HTTP du webhook est exactement 200 en <3s (plus d'ERR_ABORTED)
- Le message de succès s'affiche côté site
- Un email de confirmation arrive sur captain@netroia.com
- Une ligne apparaît dans la Google Sheet CRM (ou sera créée)

**Action requise côté site une fois livré** :
- Session site-netroia-tech retire le contournement `ok = res.status > 0`
- Rétablit `ok = res.ok` (comportement standard)
- Ajoute un message d'erreur visible dans le `catch` block (actuellement silencieux)
- Redéploie avec `deploy.ps1`

**Documents de référence** :
- `C:\Netroia\netro-automations\docs\PROMPT-COORDINATION-SITE-N8N.md`
- `C:\Netroia\Production-NetroIA\Documentation-Projets\site-netroia-tech\logs.md`
- `C:\Netroia\coordination-netroia\STATUS-BOARD.md`

---

### HANDOFF-002 — Renouvellement SSL VPS (deux certificats)

**Date ouverture** : 2026-05-21
**Statut** : [PARTIELLEMENT LIVRÉ — netroia.tech ✅ | n8n.netroia.tech 🔴 EN ATTENTE]
**Mis à jour** : 2026-05-21 — session site-netroia-tech
**Émetteur** : Orchestrateur (cette session)
**Récepteur** : session `netro-automations` (urgence n8n) + session `site-netroia-tech` (moins urgent)

**Détail des certificats** :

| Domaine | Ancienne exp. | Nouvelle exp. | Statut |
|---------|--------------|---------------|--------|
| netroia.tech | 2026-06-17 | **2026-08-18** | ✅ RENOUVELÉ |
| n8n.netroia.tech | 2026-06-07 | — | 🔴 URGENT — session netro-automations |

**✅ netroia.tech — FAIT (session site-netroia-tech 2026-05-21)** :
- Méthode : `certbot certonly --webroot -w /opt/n8n/compose/nginx`
- Renewal config mis à jour : `authenticator = standalone` → `authenticator = webroot`
- Future `certbot renew` automatique fonctionnera sans conflit port 80
- `curl -I https://netroia.tech` → HTTP/2 200 ✅

**⚠️ IMPORTANT — commande correcte pour ce VPS** :
```bash
# certbot est sur le HOST (pas dans Docker)
# nginx est dans container n8n_nginx → port 80 occupé → standalone IMPOSSIBLE
# Utiliser webroot avec le volume monté :

# netroia.tech (déjà fait)
certbot certonly --webroot -w /opt/n8n/compose/nginx -d netroia.tech -d www.netroia.tech --non-interactive --agree-tos
docker exec n8n_nginx nginx -s reload

# n8n.netroia.tech (À FAIRE — session netro-automations)
# Vérifier d'abord la config renewal : cat /etc/letsencrypt/renewal/n8n.netroia.tech.conf
# Si authenticator = standalone → même problème port 80
# Utiliser webroot du n8n nginx (vérifier le webroot_path dans n8n.conf)
```

**Critère de validation restant** :
- `certbot certificates` affiche n8n.netroia.tech → 89 jours
- `curl -I https://n8n.netroia.tech` retourne 200 sans erreur SSL

---

## Handoffs livrés (archivés)

*Aucun pour l'instant.*

---

## Protocole de création d'un nouveau handoff

```markdown
### HANDOFF-XXX — [Titre court]

**Date ouverture** : YYYY-MM-DD
**Statut** : [OUVERT]

**Émetteur** : session `{nom-session}`
**Récepteur** : session `{nom-session}`

**Contrat** :
> Description précise de ce qui doit être livré, dans quel format, avec quelles contraintes.

**Critère de validation** :
- Test concret 1
- Test concret 2

**Action requise côté récepteur une fois livré** :
- Ce que la session réceptrice doit faire après réception

**Documents de référence** :
- Chemin vers les fichiers pertinents
```

---

*Créé : 2026-05-07 — Orchestrateur NetroIA v1.0*
*Mis à jour : 2026-05-21 — HANDOFF-002 ajouté (SSL renouvellement)*
