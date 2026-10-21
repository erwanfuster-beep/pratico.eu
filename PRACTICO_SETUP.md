# Practico Home — Cozy World V3 🏡

**Un vrai petit monde qui grandit avec tes progrès dans la vie.** Site statique et responsive, hébergé sur GitHub Pages, avec authentification Supabase.

## Jouer
1. Ouvre **Mon refuge**. Tu débutes dans **Le studio oublié**, avec un vieux matelas, une caisse, 35 pièces et une météo pluvieuse cosy.
2. Termine des tâches (**+35 XP** la première validation, 8 récompenses par jour au maximum), valide des habitudes (**+25 XP**, une fois par habitude et par jour) ou termine des sessions de concentration (**+2 XP par minute**, 4 récompenses par jour maximum). Les actions restent utilisables au-delà des plafonds.
3. Chaque nouveau niveau offre des **pièces virtuelles** (aucun argent réel), utilisables dans la **Boutique**.
4. Achète des meubles originaux dessinés en SVG, puis ouvre **Mon refuge**, choisis l'objet dans ton inventaire et touche le sol pour le placer. Glisse-le au doigt ou à la souris pour le déplacer. Pour une navigation clavier, utilise **Entrée** pour sélectionner puis **les flèches** pour déplacer.
5. Change de lieu lorsque tu as le niveau et les pièces nécessaires. Tous tes meubles peuvent être installés dans chaque logement, **avec des positions indépendantes par logement**. Tu peux racheter plusieurs exemplaires du même meuble.
6. Météo : le bouton **Pluie** anime les gouttes à la fenêtre ; **Auto/Jour/Nuit** suit l'heure locale du navigateur entre 7 h et 19 h lorsqu'il est en mode Auto ; **Son** ajoute une ambiance pluvieuse optionnelle et désactivée par défaut.
7. **Mode tranquillité** : 60 secondes de respiration guidée ; premier exercice du jour **+15 XP et +5 pièces**.

## Lieux disponibles
- Niveau 1 : Le studio oublié
- Niveau 4 : La maison douce
- Niveau 6 : Le petit voilier
- Niveau 10 : La villa solaire
- Niveau 12 : Le bateau de pêche
- Niveau 13 : L'avion vintage
- Niveau 17 : Le yacht panoramique
- Niveau 19 : Le manoir des étoiles
- Niveau 24 : Le grand avion privé

Chaque logement possède ses propres couleurs, sa fenêtre et une disposition sauvegardée séparément.

## Structure
- \`index.html\` : structure et navigation
- \`practico.css\` : interface utilitaire
- \`cozy.css\` : scène illustrée, logements, boutique, pluie, mobilier, mobile
- \`cozy.js\` : moteur de jeu solo, XP, inventaire, décorations, météo
- \`practico.js\` : tâches, habitudes, notes, focus, comptes et persistance
- \`config.js\` : URL et clé **publique** Supabase (jamais une clé secrète)
- \`supabase-practico.sql\` : schéma et RLS pour la synchronisation

## À FAIRE UNE FOIS DANS SUPABASE (pour plusieurs appareils)
1. Ouvre ton projet Supabase existant.
2. Clique sur **SQL Editor**, puis **New query**.
3. Copie-colle le fichier [supabase-practico.sql](./supabase-practico.sql).
4. Clique sur **Run**.
5. Connecte-toi sur Practico puis ouvre **Mon compte** : le statut doit indiquer « Synchronisation cloud active ».

Le SQL ne supprime **aucune** ancienne table. La règle **RLS** limite les lignes aux données du propriétaire authentifié. Sans ce SQL, la connexion Auth peut fonctionner, mais tâches, notes, XP, pièces et décorations restent sauvegardés sur **cet appareil seulement**. Les données enregistrées en mode invité peuvent être reprises à la première connexion si le compte n'a pas encore de données, mais cette migration doit être testée.

## Hébergement et domaine
- Repo : https://github.com/erwanfuster-beep/pratico.eu
- GitHub Pages : https://erwanfuster-beep.github.io/pratico.eu/
- Pages : Settings > Pages > **Deploy from branch** > \`main\` / \`(root)\`.

Un dépôt nommé \`pratico.eu\` n'enregistre pas automatiquement le domaine \`practico.eu\`. Le nom de marque de l'application est **Practico**.

## Visuels et droits
Les meubles, pièces, météo et scènes sont générés à l'aide de **dessins SVG et CSS originaux** inclus dans les fichiers du site. Aucun contenu visuel de jeu tiers ni streaming n'est utilisé. L'ancienne photo Unsplash n'est plus nécessaire à l'interface principale.

## Vie privée et limites
- Jeu **solo**, 100 % virtuel, sans argent réel.
- Le client calcule les XP et pièces **dans le navigateur** ; ce n'est pas une économie compétitive anti-triche. Un mode multijoueur ou classement public demanderait des récompenses contrôlées côté serveur et des règles supplémentaires.
- Supabase Auth gère le mot de passe ; les données personnelles restent derrière des règles RLS une fois la table configurée.
- Mode invité : localStorage, susceptible d'être effacé par le navigateur.
- Un export JSON et un effacement de l'espace sont accessibles dans « Mon compte ».
- Avant ouverture publique large : mentions légales, politique de confidentialité, contact et procédure d'effacement des comptes, revue du RGPD et tests multi-appareils.

## Tests rapides
1. Dans Tâches : crée trois tâches et valide-les. Le niveau 2 devrait se débloquer et donner des pièces.
2. Dans Boutique : achète « Monstera ». Le solde doit diminuer.
3. Dans Mon refuge : sélectionne Monstera, touche le sol pour le poser et glisse-le ailleurs.
4. Actualise la page : la plante doit rester à la même position sur ce navigateur.
5. Active Pluie puis Jour/Nuit ; teste le placement sur téléphone.
6. Teste Connexion et synchronisation après exécution du SQL.
