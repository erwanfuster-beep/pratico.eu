# Practico — Budget, agenda, courses et projets

Site : https://erwanfuster-beep.github.io/pratico.eu/
Dépôt : https://github.com/erwanfuster-beep/pratico.eu

## Ce qui fonctionne maintenant

- Design clair et responsive pour ordinateur et téléphone.
- Revenu fictif de départ de **1 500 € / mois**, modifiable.
- Enveloppes mensuelles (courses, logement, transport, vacances, loisirs, santé, autres).
- Budget disponible calculé depuis les opérations de **simulation** enregistrées.
- Historique mensuel, bilan annuel et graphiques.
- Agenda pour les échéances et coûts prévus (non déduits avant validation).
- Mini-panier de courses à prix fictifs (aucun lien aux prix de Courses U), dont la simulation peut être déduite du budget.
- Projets de voyage, coûts prévus et simulations de train, vol, hôtel et location de voiture.
- Liens vers des sites marchands externes, sans suivi de commande ni paiement sur Practico.
- Connexion Supabase Auth déjà existante ; sauvegarde dans le champ JSON `finance` de `public.practico_data` et conservation des anciennes données `tasks`, `habits`, `game`, etc.
- Export JSON, réinitialisation du budget, mode invité avec stockage navigateur.

## Très important : les achats réels automatiques ne sont PAS encore activés

Le produit final envisagé : après un achat réel chez un commerçant, Practico doit enregistrer automatiquement la transaction (par exemple Ryanair -300 €, Hôtel -1 000 €) et recalculer le solde **fictif**. Pas de validation manuelle à chaque dépense.

Pour détecter **aussi** les dépenses faites en magasin et via le téléphone, une extension Chrome ne suffit pas. La voie sérieuse est l'**information sur les comptes bancaires (open banking DSP2)**, via un prestataire autorisé, en **lecture seule** et avec consentement explicite. Deux prestataires à évaluer :
- Bridge : https://docs.bridgeapi.io/docs/quickstart
- Powens : https://www.powens.com/fr/produits/transactions/

Les API exigent un accès développeur / contrat et des identifiants **secrets**, qui ne doivent jamais être mis dans `config.js` ni dans GitHub Pages. La connexion bancaire exigera un **backend sécurisé** (par ex. Supabase Edge Functions et un coffre de secrets côté serveur), la gestion du consentement, des dates d'expiration, de la déduplication des opérations, des remboursements et une politique de confidentialité adaptée.

Un parcours automatique réaliste : 
1. Utilisateur crée son budget fictif, puis choisit **Connecter mes dépenses** (fonction future).
2. Il sélectionne un prestataire/bancaire et donne son consentement via son interface officielle.
3. Le serveur sécurisé récupère uniquement les transactions permises et les inscrit sans doublons dans un registre privé.
4. Practico catégorise les marchands et recalcule le budget automatiquement (cours U → courses, Ryanair → voyages, hôtel → voyages).
5. Les opérations en attente, remboursements, espèces et commerçants ambigus sont traités séparément.
6. L'utilisateur peut déconnecter la source, corriger une catégorie et supprimer ses données.

**Attention :** les flux bancaires ne sont pas nécessairement instantanés. Le nom précis de l'article acheté peut ne pas être disponible ; souvent seul le marchand et le montant apparaissent.

Une **extension facultative**, limitée à des sites supportés, pourrait enrichir le libellé de commande, mais devra demander des permissions minimales, éviter la lecture de moyens de paiement et ne jamais tenter de contourner les protections des sites. Référence Chrome : https://developer.chrome.com/docs/extensions/mv3/declare_permissions

## Supabase

La table `public.practico_data` a déjà été configurée pour le précédent Practico. **Aucun SQL supplémentaire n'est requis pour le prototype Budget**, si la synchronisation de l'ancien site était active. Le nouveau champ `finance` est ajouté à `payload` (JSONB) sans écraser les anciens champs.

Vérifier l'onglet **Mon compte** : il affiche le statut de synchronisation.

## Sécurité / lancement public

- Aucun argent réel détenu, aucun paiement déclenché, aucun mot de passe bancaire collecté.
- Connexion Supabase seulement avec la clé **publique**.
- RLS : chaque utilisateur doit accéder uniquement à sa ligne `practico_data`.
- Tous les prix de démonstration et revenus sont fictifs.
- Le site n'affirme pas synchroniser la banque ou les achats tant que la fonctionnalité n'existe pas.
- Prévoir avant lancement public : mentions légales, confidentialité / RGPD, contact, suppression de compte et données, revue de sécurité et tests sur mobiles / avec plusieurs comptes.
- Les écritures se rapportent à chaque mois indépendant. Le *solde annuel* est une projection simple (12 × revenu mensuel – dépenses de l'année), pas le solde réel d'un compte ou un report bancaire validé.

## Sauvegarde de l'ancienne version

Branche GitHub `archive-practico-home-v3` : sauvegarde du jeu Cozy Home, mobilier, XP et ancienne interface.
