# STATUS-BOARD.md — Tableau de bord Orchestrateur NetroIA

> Mis à jour à chaque session coordinatrice. Source de vérité de l'état inter-sessions.
> **Règle** : Si ce fichier n'est pas à jour → le mettre à jour AVANT toute autre action.

---

## Vue d'ensemble — 2026-05-21 (mis à jour Orchestrateur)

| Branche | Version | État | Déployé | Bloquants |
|---------|---------|------|---------|-----------|
| site-netroia-tech | v0.4 | ✅ Production | https://netroia.tech | catch silencieux formulaire — attend HANDOFF-001 |
| netro-automations | En cours | ❌ Bloqué | n8n opérationnel | AbortController 10s > pipeline ~13s |
| Pro-Gaming-Godot | v0.2 | 🎮 Phase 1 validée | GitHub only | En attente sprites PixSquare (REQUEST-001/002) |
| NetroPraxis | — | ⏸️ Pause | — | — |

---

## Liens inter-sessions

### [ACTIF] site → n8n (Formulaire Contact CRM)

```
STATUS : ❌ BLOQUÉ — AbortController timeout 10s côté formulaire (ligne 1714 index.html)

Diagnostic complet (session coordination-netroia 2026-05-07) :

  curl → n8n   : ✅ 200 OK en ~13s
                 {"success":true,"message":"Message recu. Nous vous repondons dans les 24h."}
  Chrome → n8n : ❌ ERR_ABORTED — n8n répond en ~13s > timeout AbortController 10s
  UX site      : ❌ Formulaire silencieux (catch block, pas de message succès ni erreur)

ROOT CAUSE CONFIRMÉE :
  n8n répond en ~13 secondes (pipeline complet : Validation + GPT + Email + Slack + Sheets)
  Le formulaire a un AbortController timeout de 10 secondes (index.html ligne 1714)
  13s > 10s → controller.abort() → Chrome ERR_ABORTED → catch block → silence

  TLS renegotiation = FAUSSE PISTE (confirmé 2026-05-07)
  CORS : OK (OPTIONS 204 confirmé). Nginx config : propre.

Émetteur  : site-netroia-tech
  - URL     : https://n8n.netroia.tech/webhook/contact-netroia
  - Méthode : POST
  - Payload : { name, email, service, message, source, date }

Fix requis (session netro-automations — HANDOFF-001) :
  Repositionner "Respond to Webhook" AVANT le pipeline IA dans le workflow n8n
  → n8n répond 200 en <2s → bien en dessous du timeout 10s du formulaire
  → Pipeline IA/Email/Slack/Sheets s'exécute ensuite en asynchrone
```

---

## Infra VPS — État (2026-05-21)

```
VPS               : ✅ Running (187.124.36.81)
n8n_nginx         : ✅ Up — ports 80:80 + 443:443 bindés (fix 2026-05-07)
n8n container     : ✅ Up (healthy)
Nginx système     : ✅ Désactivé (systemctl disable nginx — fix 2026-05-07)
SSL netroia.tech  : ✅ Renouvelé — expire 2026-08-18 (89 jours) — webroot via Docker volume
SSL n8n.netroia   : 🔴 Valide — expire 2026-06-07 (17 jours) — URGENT : session netro-automations
```

> **⚠️ ALERTE SSL** : n8n.netroia.tech expire dans **17 jours** (2026-06-07).
> Action : session netro-automations doit exécuter certbot renewal via SSH VPS.

---

## Pro-Gaming-Godot — État (2026-05-21)

```
Projet            : RPG Platformer 2D Pixel Art Dark Fantasy Procédural Multi-monde
Moteur            : Godot 4.6.2 stable portable
Status            : ✅ Workspace 100% opérationnel
GitHub            : https://github.com/captainNetroia/Pro-Gaming-Godot
Commit            : v0.1.0 — 371 fichiers, feat(setup) + fix(gitignore)

Setup complété :
  ✅ Godot 4.6.2 installé (portable exe)
  ✅ Projet Godot créé : game/pro-gaming-godot/
  ✅ Plugin godot_mcp installé + activé
  ✅ Serveur MCP Pro v1.13.2 buildé (mcp/server/build/)
  ✅ .mcp.json configuré (project + user level)
  ✅ VS Code extensions configurées (godot-tools, .vscode/settings.json)
  ✅ CLAUDE.md projet créé
  ✅ GOD-game.md enrichi
  ✅ Documentation-Projets/ créé (7 fichiers)
  ✅ MCP Pro connecté ✅ (vert via session Antigravity IDE)

Phase 1 validée (2026-05-21) :
  ✅ GL Compatibility (OpenGL 3.3) actif
  ✅ Viewport 384×216 → 1152×648 pixel net
  ✅ Fond dark fantasy #17101F
  ✅ Joueur placeholder (bleu + 2 yeux) visible + physique OK
  ✅ Sol 20 tiles + StaticBody2D collision
  ✅ Input map : WASD/Espace/Shift/X/Z/F
  ✅ Camera2D suivi fluide

Prochaine étape : Phase 1 suite — Assets réels (v0.3)
  ⏳ REQUEST-001 : Sprite Marcheur (4 frames idle minimum) → créateur PixSquare
  ⏳ REQUEST-002 : Tileset Ashwood (2 tiles sol minimum) → créateur PixSquare
  → Dès livraison : AnimationPlayer + TileSet avec vrais sprites
```

---

## Prochaines actions par session

### 🔴 session netro-automations (PRIORITÉ CRITIQUE)
- [ ] **SSL n8n.netroia.tech** : SSH VPS → `certbot renew --nginx -d n8n.netroia.tech` → expire 2026-06-07 (17j)
- [ ] **HANDOFF-001** : Repositionner "Respond to Webhook" AVANT pipeline IA dans workflow CRM
- [ ] Vérifier Email / Slack / Sheets s'exécutent en async après Respond
- [ ] Tester flux complet bout-en-bout depuis Chrome (formulaire netroia.tech)

### 🟡 session site-netroia-tech (APRÈS livraison HANDOFF-001)
- [x] **SSL netroia.tech** : Renouvelé 2026-05-21 → expire 2026-08-18 — webroot, config auto mis à jour ✅
- [ ] Retirer contournement `ok = res.status > 0` → rétablir `ok = res.ok` (attend HANDOFF-001)
- [ ] Ajouter message d'erreur visible dans catch block (attend HANDOFF-001)
- [ ] Redéployer avec `deploy.ps1`
- [ ] Valider formulaire bout-en-bout depuis Chrome

### 🚀 session Pro-Gaming-Godot (PRÊTE — peut démarrer maintenant)
- [ ] Ouvrir session dans Antigravity IDE (dossier C:\Netroia\Pro-Gaming-Godot\)
- [ ] Vérifier MCP Pro vert dans Godot (panneau bas)
- [ ] Phase 1 : créer scène player.tscn (CharacterBody2D + sprite + collisions)
- [ ] Implémenter mouvement horizontal + saut + dash

### session coordination-netroia (cette session — Orchestrateur)
- [x] Diagnostic webhook Chrome + curl — FAIT 2026-05-07
- [x] Mise à jour STATUS-BOARD — FAIT 2026-05-07 + 2026-05-21
- [x] Pro-Gaming-Godot setup complet + push GitHub — FAIT 2026-05-21
- [x] Générer instructions sessions netro-automations + site-netroia-tech — FAIT 2026-05-21
- [ ] Valider le flux formulaire une fois HANDOFF-001 livré
- [ ] Clôturer HANDOFF-001 et HANDOFF-002

---

*Dernière mise à jour : 2026-05-21 — Orchestrateur NetroIA v1.2*
