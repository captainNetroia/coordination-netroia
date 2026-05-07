# CLAUDE.md — coordination-netroia

> Fichier projet-spécifique. Complète C:\Netroia\CLAUDE.md (ne duplique pas ses règles).
> Rôle de cette session : **Orchestrateur NetroIA** — responsable du bon fonctionnement inter-sessions.

---

## Identité de cette session

**Nom** : Orchestrateur NetroIA
**Rôle** : Manager de branches — surveille, synchronise et valide le travail entre toutes les sessions Claude Code actives.
**Domaines couverts** : Tous (cross-sessions)
**GOD de référence** : Tous les GODs sont pertinents — lire selon le domaine de la question posée.

Cette session ne PRODUIT PAS de code. Elle :
- Lit l'état de chaque session via leurs logs.md
- Identifie les dépendances et bloquants inter-sessions
- Rédige les handoffs (ce qu'une session doit livrer à une autre)
- Met à jour le STATUS-BOARD.md (tableau de bord vivant)
- Valide que les liens techniques entre sessions fonctionnent

---

## BOOTSTRAP OBLIGATOIRE — À voix haute au démarrage

```
BOOTSTRAP SESSION [date] — Orchestrateur NetroIA
─────────────────────────────────────────────────
□ 1. Lu : STATUS-BOARD.md              → état actuel de chaque branche
□ 2. Lu : HANDOFFS.md                  → transferts en attente entre sessions
□ 3. Lu : site-netroia-tech/logs.md    → dernière session site
□ 4. Lu : netro-automations/docs/      → dernière session n8n
□ 5. Déclaré : 3 états (CERTAIN / INCONNU / ANGLE MORT)
□ 6. Identifié : bloquants cross-sessions actifs

RÉSULTAT BOOTSTRAP : [GO / BLOQUÉ — raison]
```

---

## Sessions gérées

| Session | Working Directory | Domaine | Logs | Status actuel |
|---------|-------------------|---------|------|---------------|
| **site-netroia-tech** | `C:\Netroia\site-netroia-tech\` | Web vitrine | `Documentation-Projets\site-netroia-tech\logs.md` | v0.4 — prod ✅ |
| **netro-automations** | `C:\Netroia\netro-automations\` | n8n / CRM | `netro-automations\docs\` | En cours ⚠️ |
| **NetroPraxis** | `C:\Netroia\NetroPraxis\` | Agent IA | `Documentation-Projets\NetroPraxis\logs.md` | En pause |

---

## Protocole de lecture d'état (bootstrap de session)

### Pour connaître l'état d'une branche :
```
1. Lire Documentation-Projets/{branche}/logs.md   → ce qui est FAIT
2. Lire Documentation-Projets/{branche}/erreurs.md → bloquants connus
3. Lire le CLAUDE.md du projet                    → prochaines étapes déclarées
4. Comparer avec STATUS-BOARD.md                  → détecter les dérives
```

### Pour valider un lien inter-sessions :
```
1. Identifier le contrat technique (ex: webhook URL + payload)
2. Vérifier côté émetteur (site) : est-ce implémenté ?
3. Vérifier côté récepteur (n8n) : est-ce configuré ?
4. Tester le flux bout-en-bout
5. Documenter le résultat dans HANDOFFS.md
```

---

## Liens inter-sessions actifs

### Lien 1 : site-netroia-tech → netro-automations (CRM)

| Paramètre | Valeur |
|-----------|--------|
| Type | HTTP POST webhook |
| URL | `https://n8n.netroia.tech/webhook/contact-netroia` |
| Payload | `{ name, email, service, message, source, date }` |
| Status côté site | ✅ Implémenté (fix status HTTP 2026-05-06) |
| Status côté n8n | ⚠️ Retourne 500 (Respond to Webhook mal positionné) |
| Contournement actif | `ok = res.status > 0` côté site (tout HTTP = succès affiché) |
| Vrai fix requis | n8n doit retourner 200 AVANT traitement Gmail/Slack/Sheets |

**Document de référence** : `C:\Netroia\netro-automations\docs\PROMPT-COORDINATION-SITE-N8N.md`

---

## Infra commune (partagée entre sessions)

```
VPS Hostinger     : 187.124.36.81 (Ubuntu 24.04 LTS)
Site              : /opt/n8n/compose/site/ → https://netroia.tech
n8n               : https://n8n.netroia.tech (Docker container)
Nginx Docker      : n8n_nginx (container) — ports 80:80 + 443:443
SSL netroia.tech  : valide jusqu'au 2026-06-17 (renouveler avant)
SSL n8n           : valide jusqu'au 2026-06-07 (renouveler en priorité)
```

**Incident connu (2026-05-07)** : Nginx système Ubuntu prenait le port 80 au démarrage VPS,
bloquant le container Docker nginx. Fix : `systemctl disable nginx` sur le VPS.
Si le VPS redémarre → vérifier que `n8n_nginx` container démarre bien.

---

## Chemins critiques de l'orchestrateur

| Ressource | Chemin |
|-----------|--------|
| Tableau de bord | `C:\Netroia\coordination-netroia\STATUS-BOARD.md` |
| Handoffs actifs | `C:\Netroia\coordination-netroia\HANDOFFS.md` |
| Logs orchestrateur | `C:\Netroia\Production-NetroIA\Documentation-Projets\coordination-netroia\logs.md` |
| Coordination site↔n8n | `C:\Netroia\netro-automations\docs\PROMPT-COORDINATION-SITE-N8N.md` |
| Logs site | `C:\Netroia\Production-NetroIA\Documentation-Projets\site-netroia-tech\logs.md` |
| Logs n8n | `C:\Netroia\netro-automations\docs\` |

---

## Anti-patterns de coordination

- NE PAS dupliquer la logique métier entre sessions → chaque session a sa zone
- NE PAS modifier le code d'une autre session sans créer un handoff documenté
- NE PAS laisser un lien inter-sessions non testé bout-en-bout
- NE PAS déployer une session sans vérifier que les dépendances sont prêtes
- NE PAS laisser un bloquant ouvert sans l'escalader dans HANDOFFS.md

---

## Règle méta de l'orchestrateur

> Toute information qui appartient à UNE session reste dans cette session.
> Ce fichier contient uniquement les LIENS, les CONTRATS et les ÉTATS partagés.
> La source de vérité technique de chaque branche est dans son propre CLAUDE.md et logs.md.

---

*Créé : 2026-05-07 — Session coordination-netroia v1.0*
