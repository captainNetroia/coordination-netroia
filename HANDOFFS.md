# HANDOFFS.md — Transferts inter-sessions NetroIA

> Ce fichier liste les contrats de livraison entre sessions.
> Chaque handoff = une session qui doit livrer quelque chose à une autre.
> Format : [OUVERT] → en attente | [LIVRÉ] → terminé | [VALIDÉ] → testé bout-en-bout

---

## Handoffs actifs

---

### HANDOFF-001 — n8n retourne 200 propre au formulaire site

**Date ouverture** : 2026-05-06
**Statut** : [OUVERT]

**Émetteur** (qui doit livrer) : session `netro-automations`
**Récepteur** (qui attend) : session `site-netroia-tech`

**Contrat** :
> La session netro-automations doit configurer le workflow n8n pour qu'il réponde 200 OK
> au webhook contact AVANT le traitement Gmail/Slack/Sheets.
> Architecture cible : Webhook → Validation → Respond 200 → [Classification IA → Email → Slack → Sheets]

**Critère de validation** :
- Soumettre le formulaire sur https://netroia.tech
- La réponse HTTP du webhook est exactement 200
- Le message de succès s'affiche côté site
- Un email de confirmation arrive sur captain@netroia.com
- Une ligne apparaît dans la Google Sheet CRM

**Action requise côté site une fois livré** :
- Session site-netroia-tech retire le contournement `ok = res.status > 0`
- Rétablit `ok = res.ok` (comportement standard)
- Redéploie avec `deploy.ps1`

**Documents de référence** :
- `C:\Netroia\netro-automations\docs\PROMPT-COORDINATION-SITE-N8N.md`
- `C:\Netroia\Production-NetroIA\Documentation-Projets\site-netroia-tech\logs.md` (section dette technique)

---

## Handoffs livrés (archivés)

*Aucun pour l'instant — premier démarrage de la session coordinatrice.*

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
