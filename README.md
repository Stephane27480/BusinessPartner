# BusinessPartner

## Idée :
Permettre de lire les données de l'insee en fonction LIVE pour les creations qui ne sont pas dans la base
Stocker pour nos clients les SIREN qu'ils ont en surveillance
Quand un etablissement chez un client ou fournisseur ferme ou ouvre faut il avertir quelqu'un ?
Tous les mois il faut charger la base 

https://www.data.gouv.fr/fr/datasets/base-sirene-des-entreprises-et-de-leurs-etablissements-siren-siret/
https://api.insee.fr/catalogue/site/themes/wso2/subthemes/insee/pages/item-info.jag?name=Sirene&version=V3&provider=insee

Il faudra donc voir comment stocker ces données a moindre cout.
- Gérer les abonnements pour les clients
  - [ ] Faire une application FIORI pour la gestion des abonnements
  - [ ] Attention potentiellement lié avec un paiement en ligne
- Lors de la création si le SIREN/SIRET n'est pas dans la liste voir le live 
- Lors de la création proposer la liste des etablissements (uniquement sans date de fin)
- Faire la gestion des fournisseurs & Client et l'intégration SAP S4H (et MDG ?)
- Faire un workflow d'alerte quand l'un des comptes surveillé a des créations ou supression

