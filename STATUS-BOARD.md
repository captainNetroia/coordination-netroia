# STATUS-BOARD.md — Tableau de bord Orchestrateur NetroIA

> Mis à jour à chaque session coordinatrice. Source de vérité de l'état inter-sessions.
> **Règle** : Si ce fichier n'est pas à jour → le mettre à jour AVANT toute autre action.

---

## Vue d'ensemble — 2026-05-07

| Branche | Version | État | Déployé | Bloquants |
|---------|---------|------|---------|-----------|
| site-netroia-tech | v0.4 | ✅ Production | https://netroia.tech | Aucun |
| netro-automations | En cours | ⚠️ Partiel | n8n opérationnel | Workflow retourne 500 |
| NetroPraxis | — | ⏸️ Pause | — | — |

---

## Liens inter-sessions

### [ACTIF] site → n8n (Formulaire Contact CRM)

```
STATUS : ⚠️ PARTIEL — fonctionne avec contournement

Émetteur  : site-netroia-tech
  - URL   : https://n8n.netroia.tech/webhook/contact-netroia
  - Méthode : POST
  - Payload : { name, email, service, message, source, date }
  - Fix actif : ok = res.status > 0 (contournement du 500 n8n)

Récepteur : netro-automations (workflow "NetroIA - CRM Formulaire Contact")
  - ÉTAPE 1 : Webhook + Validation ✅
  - ÉTAPE 2 : Classification IA (gpt-4.1-mini) ✅
  - ÉTAPE 3 : Génération email (gpt-4.1) ✅
  - ÉTAPE 4 : Envoyer Email + Slack + Sheets + Réponse HTTP ⚠️

Problème root : ÉTAPE 4 échoue (credentials ou SPREADSHEET_ID manquant)
→ Respond to Webhook jamais atteint → n8n retourne 500
→ Site affiche succès grâce au contournement

Fix requis (session netro-automations) :
  P1 : Déplacer Respond to Webhook EN DÉBUT de ÉTAPE 4
  P2 : Créer Google Sheet "CRM NetroIA - Leads" + configurer SPREADSHEET_ID
  P3 : Vérifier credentials Gmail, Slack, Sheets, OpenAI
```

---

## Infra VPS — État (2026-05-07)

```
VPS               : ✅ Running (187.124.36.81)
n8n_nginx         : ✅ Up — ports 80:80 + 443:443 bindés (fix 2026-05-07)
n8n container     : ✅ Up 7h+ (healthy)
Nginx système     : ✅ Désactivé (systemctl disable nginx — fix 2026-05-07)
SSL netroia.tech  : ✅ Valide — expire 2026-06-17 (40 jours)
SSL n8n.netroia   : ⚠️ Expire 2026-06-07 (31 jours) — À RENOUVELER EN PRIORITÉ
```

---

## Prochaines actions par session

### session netro-automations (PRIORITÉ HAUTE)
- [ ] P1 — Repositionner Respond to Webhook avant Gmail/Slack
- [ ] P2 — Créer Google Sheet CRM + configurer SPREADSHEET_ID
- [ ] P3 — Valider credentials Gmail, Slack, Sheets, OpenAI
- [ ] Tester bout-en-bout depuis le formulaire netroia.tech

### session site-netroia-tech (BASSE PRIORITÉ)
- [ ] Favicon `.ico` depuis logo-transparent.png
- [ ] Retirer contournement `ok = res.status > 0` une fois n8n fixé
- [ ] Renouvellement SSL avant 2026-06-07 (certbot renew)

### session coordination-netroia (cette session)
- [ ] Valider le flux complet site → n8n une fois n8n fixé
- [ ] Documenter le handoff résolu dans HANDOFFS.md

---

*Dernière mise à jour : 2026-05-07 — Session coordinatrice v1.0*
