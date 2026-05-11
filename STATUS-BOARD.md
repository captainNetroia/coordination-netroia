# STATUS-BOARD.md — Tableau de bord Orchestrateur NetroIA

> Mis à jour à chaque session coordinatrice. Source de vérité de l'état inter-sessions.
> **Règle** : Si ce fichier n'est pas à jour → le mettre à jour AVANT toute autre action.

---

## Vue d'ensemble — 2026-05-07 (mis à jour 13h16)

| Branche | Version | État | Déployé | Bloquants |
|---------|---------|------|---------|-----------|
| site-netroia-tech | v0.4 | ✅ Production | https://netroia.tech | catch silencieux formulaire |
| netro-automations | En cours | ❌ Bloqué | n8n opérationnel | TLS renegotiation nginx → Chrome ERR_ABORTED |
| NetroPraxis | — | ⏸️ Pause | — | — |

---

## Liens inter-sessions

### [ACTIF] site → n8n (Formulaire Contact CRM)

```
STATUS : ❌ BLOQUÉ — Chrome ERR_ABORTED (TLS renegotiation nginx)

Diagnostic session coordination-netroia 2026-05-07 13h16 (curl + Chrome DevTools) :

  curl → n8n   : ✅ 200 OK en ~13s
                 {"success":true,"message":"Message recu. Nous vous repondons dans les 24h."}
  Chrome → n8n : ❌ ERR_ABORTED — nginx demande 2x TLS renegotiation, Chrome refuse
  UX site      : ❌ Formulaire silencieux (catch block, pas de message succès ni erreur)
                 Le contournement ok = res.status > 0 est INOPÉRANT ici
                 (fetch() throw avant d'avoir res quand ERR_ABORTED)

Émetteur  : site-netroia-tech
  - URL     : https://n8n.netroia.tech/webhook/contact-netroia
  - Méthode : POST
  - Payload : { name, email, service, message, source, date }

Récepteur : netro-automations (workflow "NetroIA - CRM Formulaire Contact")
  - Répond 200 ✅ (confirmé curl — l'ancien bloquant 500 semble résolu)
  - Email / Slack / Sheets : ❓ INCONNU — non vérifié depuis Chrome ERR_ABORTED

ROOT CAUSE RÉELLE (identifiée 2026-05-07 session coordination-netroia) :
  n8n répond en ~13 secondes (pipeline complet : Validation + GPT + Email + Slack + Sheets)
  Le formulaire a un AbortController timeout de 10 secondes (index.html ligne 1714)
  13s > 10s → controller.abort() → Chrome ERR_ABORTED → catch block → silence

  Note : "TLS renegotiation" vue dans curl (Windows Schannel) = fausse piste.
  CORS : OK (OPTIONS 204 confirmé). Nginx config : propre, aucun problème SSL.

Fix requis (session netro-automations — HANDOFF-001 toujours valide) :
  Repositionner "Respond to Webhook" AVANT le pipeline IA dans le workflow n8n
  → n8n répond 200 en <2s → bien en dessous du timeout 10s du formulaire
  → Pipeline IA/Email/Slack/Sheets s'exécute ensuite en asynchrone
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

### VPS / infra (PRIORITÉ CRITIQUE)
- [ ] SSH VPS → inspecter /opt/n8n/compose/nginx.conf
- [ ] Identifier la directive qui déclenche TLS renegotiation
- [ ] Corriger + restart container n8n_nginx
- [ ] Valider avec Chrome DevTools : plus d'ERR_ABORTED sur POST webhook

### session netro-automations (PRIORITÉ HAUTE — après fix nginx)
- [ ] Vérifier que Email / Slack / Sheets s'exécutent bien (n8n logs)
- [ ] Créer Google Sheet "CRM NetroIA - Leads" + configurer SPREADSHEET_ID
- [ ] Valider credentials Gmail, Slack, Sheets, OpenAI
- [ ] Tester flux complet bout-en-bout depuis Chrome

### session site-netroia-tech (APRÈS fix nginx + n8n validé)
- [ ] Retirer contournement `ok = res.status > 0` → rétablir `ok = res.ok`
- [ ] Ajouter message d'erreur visible dans le catch block (UX dégradée actuellement)
- [ ] Favicon `.ico` depuis logo-transparent.png
- [ ] Renouvellement SSL avant 2026-06-07 (certbot renew)

### session coordination-netroia (cette session)
- [x] Diagnostic webhook Chrome + curl — FAIT 2026-05-07
- [x] Mise à jour STATUS-BOARD + HANDOFFS — FAIT 2026-05-07
- [ ] Valider le flux complet une fois nginx fixé
- [ ] Clôturer HANDOFF-001 et HANDOFF-002

---

*Dernière mise à jour : 2026-05-07 13h16 — Session coordinatrice v1.1*
