# Practico — ton espace quotidien

Practico remplace le jeu Pratico Multiverse par une application de productivite personnelle, gratuite et adaptee au mobile.

## Fonctionnalites
- Tableau de bord : compteur des taches, habitudes, minutes de focus et activite sur sept jours.
- Taches : ajouter, terminer, supprimer, filtrer.
- Habitudes : creer, suivre chaque jour, suggestions de bonnes habitudes.
- Focus : minuteur 15/25/45 minutes, pause et progression.
- Notes : rediger, modifier, supprimer.
- Export JSON des donnees personnelles.
- Mode invite sans connexion : sauvegarde locale dans ce navigateur.
- Supabase Auth : inscription et connexion. Cloud une fois la table installee.
- Affichage adapte aux telephones.

## ACTION REQUISE : activer le cloud Supabase
1. Ouvre ton projet Supabase existant, sans creer de nouveau projet.
2. Dans SQL Editor, clique sur New query.
3. Ouvre le fichier supabase-practico.sql de ce depot et colle son contenu.
4. Clique sur Run.
5. Dans Practico > Mon compte, une fois connecte, verifie « Synchronisation cloud active ».

Le script ne supprime aucune ancienne table et protege les donnees de chaque utilisateur avec Row Level Security (RLS). Tant que tu ne l'as pas execute, l'application continue a fonctionner mais les taches, habitudes et notes restent sur le navigateur utilise seulement.

## GitHub Pages
Depot : https://github.com/erwanfuster-beep/pratico.eu
Site : https://erwanfuster-beep.github.io/pratico.eu/

Reglage conseille : Settings > Pages > Deploy from branch > main / (root).

Le nom du depot n'achete pas un domaine. Si tu veux practico.eu, il faudra posseder ce domaine et configurer DNS, Pages et CNAME.

## Securite / vie privee
- Uniquement une cle publique Supabase cote navigateur, jamais la cle service_role.
- Les comptes utilisent Supabase Auth et les donnees sont isolees via RLS.
- Export JSON disponible dans Mon compte.
- En cas d'usage public, prevoir mentions legales, politique de confidentialite, un contact et un processus d'effacement des donnees et du compte.
- Le mode invite est local ; effacer le navigateur peut faire perdre les donnees. Faire un export au besoin.
- Prototype : tester la connexion et la synchronisation avant de faire venir de nombreux utilisateurs.

## Photo
Photo de Matus Gocman : https://unsplash.com/photos/a-desk-with-a-notebook-pen-and-a-plant-KB2z8sJpSg8
Licence : https://unsplash.com/license
