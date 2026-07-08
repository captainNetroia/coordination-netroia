# STATUS-BOARD.md — Tableau de bord Orchestrateur NetroIA

> Mis à jour à chaque session coordinatrice. Source de vérité de l'état inter-sessions.
> **Règle** : Si ce fichier n'est pas à jour → le mettre à jour AVANT toute autre action.

---

## Vue d'ensemble — 2026-07-08 (mis à jour, était obsolète depuis le 21/05)

> **NOTE IMPORTANTE (2026-07-08)** : ce tableau n'avait pas été touché depuis le 21 mai — NEOGEN
> (ex-VIVARIUM) est devenu le projet majeur du workspace depuis, absent de la version précédente.
> Voir `C:\Netroia\CONTEXT-ACTIF.md` pour l'état RPG/XP complet et le détail des dernières
> sessions — ce fichier-ci reste focalisé sur les bloquants ET liens cross-sessions.

| Branche | Version | État | Déployé | Bloquants |
|---------|---------|------|---------|-----------|
| **NEOGEN** (ex-VIVARIUM) | v24+ | ✅ En prod | https://neogen.netroia.tech (VPS 76.13.53.162) | Ollama local (VPS 2 vCPU) trop lent pour génération réelle — avertissement ajouté 08/07 |
| site-netroia-tech | v0.4 | ✅ Production | https://netroia.tech | à revérifier — état non confirmé depuis mai |
| netro-automations | En cours | ⚠️ À revérifier | n8n opérationnel | AbortController 10s > pipeline ~13s (état mai, non reconfirmé) |
| Pro-Gaming-Godot | v0.2 | 🎮 Phase 1 validée | GitHub only | En attente sprites PixSquare (REQUEST-001/002) |
| NetroPraxis | — | ⏸️ Pause | — | — |

---

## NEOGEN — État détaillé (2026-07-08)

```
VPS         : 76.13.53.162 (Hostinger, Ubuntu 24.04 LTS, srv1792379) — DIFFÉRENT du VPS
              netroia.tech/n8n (187.124.36.81) — ne pas confondre les deux VPS.
SSH         : ssh -i C:\Users\adrie\.ssh\id_ed25519 root@76.13.53.162 — CONFIRMÉ fonctionnel
              (une mémoire précédente affirmait à tort "pas d'accès SSH", corrigée le 08/07)
Repos       : origin = captainNetroia/VIVARIUM.git, public = captainNetroia/NEOGEN.git
              (le VPS clone "public" — TOUJOURS pousser sur les 2 remotes)
Déploiement : webhook https://neogen.netroia.tech/_deploy/deploy (secret dans
              credentials/neogen-deploy-webhook.env) → git pull + docker rebuild
Ollama VPS  : installé le 05/07, qwen2.5, adressable via 172.20.0.1:11434 (interne Docker),
              mais 2 vCPU seulement → /api/tags instantané, /v1/chat/completions réel TIMEOUT.
              Décision 08/07 : garder tel quel + avertissement UI, ne pas upgrader le VPS pour
              l'instant (coût non validé).
Commits 08/07 : fa19e0c (fix mobile) → c103201 (refonte visuelle) → fb10929 (fix sécurité
              paiement + fix Ollama local sur poste dev, distinct du pb Ollama-VPS ci-dessus)
```

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
- [ ] **SSL n8n.netroia.tech** : ⚠️ UTILISER WEBROOT (standalone échoue — port 80 Docker occupé)
      `certbot certonly --webroot -w /opt/n8n/compose/nginx -d n8n.netroia.tech --non-interactive --agree-tos`
      `docker exec n8n_nginx nginx -s reload`
      → expire 2026-06-07 (17j) — Briefing complet : `docs/PROMPT-SESSION-NETRO-AUTOMATIONS-2026-05-21.md`
- [ ] **HANDOFF-001** : Déplacer "Réponse HTTP 200" APRÈS "Extraire & Valider", AVANT "Classifier Demande"
      Workflow `Icz9Mh20mWcZHHQy` — branche Webhook Contact uniquement
- [ ] Test curl timing <3s + test navigateur formulaire
- [ ] Marquer HANDOFF-001 [LIVRÉ] dans HANDOFFS.md

### 🟡 session site-netroia-tech (APRÈS livraison HANDOFF-001)
- [x] **SSL netroia.tech** : Renouvelé 2026-05-21 → expire 2026-08-18 — webroot, config auto mis à jour ✅
- [ ] Retirer contournement `ok = res.status > 0` → rétablir `ok = res.ok` (attend HANDOFF-001)
- [ ] Ajouter message d'erreur visible dans catch block (attend HANDOFF-001)
- [ ] Redéployer avec `deploy.ps1`
- [ ] Valider formulaire bout-en-bout depuis Chrome

### 🎮 session Pro-Gaming-Godot (Phase 1 validée — en attente sprites)
- [x] Phase 1 validée — joueur placeholder, sol, caméra, input map ✅
- [ ] REQUEST-001 : Sprite Marcheur (4 frames idle) — en attente PixSquare
- [ ] REQUEST-002 : Tileset Ashwood (2 tiles sol) — en attente PixSquare
- [ ] Phase 1 suite (v0.3) : AnimationPlayer + vrais sprites dès livraison assets

### session coordination-netroia (cette session — Orchestrateur)
- [x] Diagnostic webhook Chrome + curl — FAIT 2026-05-07
- [x] Mise à jour STATUS-BOARD — FAIT 2026-05-07 + 2026-05-21
- [x] Pro-Gaming-Godot setup complet + push GitHub — FAIT 2026-05-21
- [x] Générer instructions sessions netro-automations + site-netroia-tech — FAIT 2026-05-21
- [ ] Valider le flux formulaire une fois HANDOFF-001 livré
- [ ] Clôturer HANDOFF-001 et HANDOFF-002

---

*Dernière mise à jour : 2026-05-21 — Orchestrateur NetroIA v1.2*
