# Game Tracker 🎮

Application web de suivi de jeux vidéo écrite en **Swift**, exécutable directement dans **GitHub Codespaces** — sans Xcode ni macOS requis.

Le serveur web est alimenté par **Hummingbird**, les données sont persistées dans **SQLite**, et l'interface est rendue en HTML côté serveur directement dans le navigateur.

---

## Fonctionnalités

- Affichage de la liste de tous les jeux enregistrés
- Ajout d'un nouveau jeu via un formulaire
- Marquage d'un jeu comme **terminé** ou **non terminé**
- Persistance des données dans une base SQLite locale (`db.sqlite3`)

---

## Structure du projet

```
.devcontainer/
  devcontainer.json       # Configuration Codespaces (Swift 6.2, extensions VS Code, port forwarding)
Sources/App/
  main.swift              # Point d'entrée — démarrage du serveur et définition des routes HTTP
  Models.swift            # Modèle de données : struct GameItem
  Database.swift          # Initialisation SQLite et requêtes (lecture, ajout, toggle)
  Views.swift             # Rendu HTML des pages renvoyées au navigateur
Package.swift             # Définition du package Swift (dépendances, cibles de build)
build.sh                  # Script utilitaire : résolution des dépendances + compilation
run.sh                    # Script utilitaire : démarrage du serveur
```

---

## Lancer le projet

### 1. Ouvrir dans GitHub Codespaces

1. Dans ton dépôt, clique sur le bouton vert **Code**.
2. Ouvre l'onglet **Codespaces** et clique sur **Create codespace on main**.
3. Attends que le conteneur se construise — le premier démarrage télécharge l'image Docker Swift (~1 Go) et exécute `swift package resolve` automatiquement.

Une fois prêt, VS Code s'ouvre dans le navigateur avec Swift entièrement configuré.

### 2. Compiler

```bash
./build.sh
```

### 3. Démarrer le serveur

```bash
./run.sh
```

Codespaces détecte que le port **8080** est utilisé et affiche une popup — clique sur **Open in Browser** (ou retrouve-le dans l'onglet **Ports**).

> Pour arrêter le serveur : `Ctrl + C`

---

## Comment ça fonctionne

```
Navigateur  →  Requête HTTP
                    ↓
              main.swift  (le routeur Hummingbird intercepte la route)
                    ↓
              Database.swift  (SQLite.swift lit/écrit dans db.sqlite3)
                    ↓
              Views.swift  (construit une page HTML à partir des données)
                    ↓
              Réponse HTTP  →  Le navigateur affiche la page
```

| Couche              | Fichier           | Technologie                                                              |
|---------------------|-------------------|--------------------------------------------------------------------------|
| Serveur & routing   | `main.swift`      | [Hummingbird 2](https://github.com/hummingbird-project/hummingbird)      |
| Modèle de données   | `Models.swift`    | Swift `struct`                                                           |
| Base de données     | `Database.swift`  | [SQLite.swift](https://github.com/stephencelis/SQLite.swift)             |
| Interface / HTML    | `Views.swift`     | HTML généré côté serveur + [Pico CSS](https://picocss.com)               |

---

## Routes HTTP

| Méthode | Route          | Description                              |
|---------|----------------|------------------------------------------|
| `GET`   | `/`            | Affiche la liste de tous les jeux        |
| `POST`  | `/add`         | Ajoute un nouveau jeu (formulaire HTML)  |
| `POST`  | `/toggle/:id`  | Inverse l'état terminé/non terminé du jeu |

---

## Modèle de données

```swift
struct GameItem: Codable, Sendable {
    let id: Int64?
    var title: String
    var isCompleted: Bool
}
```

La table SQLite correspondante :

| Colonne        | Type    | Description                      |
|----------------|---------|----------------------------------|
| `id`           | INTEGER | Clé primaire, auto-incrémentée   |
| `title`        | TEXT    | Nom du jeu                       |
| `is_completed` | BOOLEAN | Jeu terminé (true) ou non (false)|

---

## Concepts Swift illustrés

| Concept              | Où l'observer                                              |
|----------------------|------------------------------------------------------------|
| `struct`             | `Models.swift`, `Database.swift`, `Views.swift`            |
| `async/await`        | `main.swift` — `app.runService()`, handlers de routes      |
| Closures             | `main.swift` — blocs `{ request, context in ... }`         |
| Conformance protocol | `Views.swift` — `HTML: ResponseGenerator`                  |
| `throws` / `try`     | `Database.swift` — tous les appels base de données         |
| Extensions           | `Database.swift` — `Connection: @unchecked Sendable`       |

---

## Étendre le projet

### `Models.swift` — Enrichir le modèle

Ajoute des champs supplémentaires à `GameItem` selon tes besoins :

```swift
struct GameItem: Codable, Sendable {
    let id: Int64?
    var title: String
    var isCompleted: Bool
    // Exemples d'extensions :
    // var platform: String
    // var rating: Int
    // var genre: String
    // var addedDate: String
}
```

### `Database.swift` — Nouvelles requêtes

Mets à jour les colonnes de la table et ajoute des fonctions pour les nouvelles opérations (filtrage, suppression, mise à jour de champs).

### `Views.swift` — Modifier l'interface

Adapte `renderIndex(items:)` pour afficher tes données différemment. Ajoute de nouvelles fonctions `render...()` pour des pages supplémentaires.

### `main.swift` — Ajouter des routes

Enregistre de nouvelles routes en suivant le pattern existant :

```swift
router.get("/my-page") { _, _ -> HTML in
    // récupère les données et retourne une View
}

router.post("/my-action") { request, context -> Response in
    // traite la soumission d'un formulaire
}
```

---

## Dépannage

**Le port 8080 est déjà utilisé**

```bash
lsof -i :8080
kill <PID>
./run.sh
```

**Erreur `error: 'App' product not found` ou erreur de build au premier lancement**

```bash
swift package resolve
./build.sh
```

**Le Codespace est lent au démarrage**

Le premier build télécharge l'image Docker Swift (~1 Go). Les démarrages suivants sont bien plus rapides car l'image est mise en cache.

**Les modifications ne s'affichent pas dans le navigateur**

Le serveur doit être redémarré après chaque modification du code :

```bash
Ctrl + C
./build.sh
./run.sh
```

---

## Technologies utilisées

- Swift 6.2
- Hummingbird 2 (serveur web)
- SQLite.swift (accès base de données)
- Pico CSS (style HTML minimal)
- GitHub Codespaces (environnement de développement)
