# Game Tracker 🎮

A web application to track video games, written in **Swift**, runnable directly in **GitHub Codespaces** — no Xcode or macOS required.

The web server is powered by **Hummingbird**, data is persisted in **SQLite**, and the interface is rendered as HTML server-side directly in the browser.

---

## Features

- Display the full list of registered games
- Add a new game via a form
- Mark a game as **completed** or **not completed**
- Persistent data storage in a local SQLite database (`db.sqlite3`)

---

## Project Structure

```
.devcontainer/
  devcontainer.json       # Codespaces config (Swift 6.2, VS Code extensions, port forwarding)
Sources/App/
  main.swift              # Entry point — server startup and HTTP route definitions
  Models.swift            # Data model: GameItem struct
  Database.swift          # SQLite setup and queries (fetch, add, toggle)
  Views.swift             # HTML page rendering returned to the browser
Package.swift             # Swift package definition (dependencies, build targets)
build.sh                  # Helper script: resolve dependencies + compile
run.sh                    # Helper script: start the server
```

---

## Running the Project

### 1. Open in GitHub Codespaces

1. In your repository, click the green **Code** button.
2. Open the **Codespaces** tab and click **Create codespace on main**.
3. Wait for the container to build — the first start downloads the Swift Docker image (~1 GB) and runs `swift package resolve` automatically.

Once ready, VS Code opens in the browser with Swift fully configured.

### 2. Build

```bash
./build.sh
```

### 3. Start the server

```bash
./run.sh
```

Codespaces detects that port **8080** is in use and shows a popup — click **Open in Browser** (or find it under the **Ports** tab).

> To stop the server: `Ctrl + C`

---

## How It Works

```
Browser  →  HTTP Request
                ↓
          main.swift  (Hummingbird router matches the route)
                ↓
          Database.swift  (SQLite.swift reads/writes db.sqlite3)
                ↓
          Views.swift  (builds an HTML page from the data)
                ↓
          HTTP Response  →  Browser renders the page
```

| Layer             | File             | Technology                                                               |
|-------------------|------------------|--------------------------------------------------------------------------|
| Server & routing  | `main.swift`     | [Hummingbird 2](https://github.com/hummingbird-project/hummingbird)      |
| Data model        | `Models.swift`   | Swift `struct`                                                           |
| Database          | `Database.swift` | [SQLite.swift](https://github.com/stephencelis/SQLite.swift)             |
| UI / HTML         | `Views.swift`    | Server-side HTML + [Pico CSS](https://picocss.com)                       |

---

## HTTP Routes

| Method | Route         | Description                               |
|--------|---------------|-------------------------------------------|
| `GET`  | `/`           | Displays the full list of games           |
| `POST` | `/add`        | Adds a new game (HTML form submission)    |
| `POST` | `/toggle/:id` | Toggles the completed/not completed state |

---

## Data Model

```swift
struct GameItem: Codable, Sendable {
    let id: Int64?
    var title: String
    var isCompleted: Bool
}
```

Corresponding SQLite table:

| Column         | Type    | Description                         |
|----------------|---------|-------------------------------------|
| `id`           | INTEGER | Primary key, auto-incremented       |
| `title`        | TEXT    | Game title                          |
| `is_completed` | BOOLEAN | Game completed (true) or not (false)|

---

## Swift Concepts Illustrated

| Concept              | Where to find it                                          |
|----------------------|-----------------------------------------------------------|
| `struct`             | `Models.swift`, `Database.swift`, `Views.swift`           |
| `async/await`        | `main.swift` — `app.runService()`, route handlers         |
| Closures             | `main.swift` — `{ request, context in ... }` blocks       |
| Protocol conformance | `Views.swift` — `HTML: ResponseGenerator`                 |
| `throws` / `try`     | `Database.swift` — all database calls                     |
| Extensions           | `Database.swift` — `Connection: @unchecked Sendable`      |

---

## Extending the Project

### `Models.swift` — Enrich the model

Add extra fields to `GameItem` as needed:

```swift
struct GameItem: Codable, Sendable {
    let id: Int64?
    var title: String
    var isCompleted: Bool
    // Examples:
    // var platform: String
    // var rating: Int
    // var genre: String
    // var addedDate: String
}
```

### `Database.swift` — New queries

Update the table columns to match your model, and add functions for new operations (filtering, deleting, updating fields).

### `Views.swift` — Change the UI

Modify `renderIndex(items:)` to display your data differently. Add new `render...()` functions for additional pages.

### `main.swift` — Add routes

Register new routes following the existing pattern:

```swift
router.get("/my-page") { _, _ -> HTML in
    // fetch data, return a View
}

router.post("/my-action") { request, context -> Response in
    // handle form submission
}
```

---

## Troubleshooting

**Port 8080 is already in use**

```bash
lsof -i :8080
kill <PID>
./run.sh
```

**`error: 'App' product not found` or build errors on first open**

```bash
swift package resolve
./build.sh
```

**Codespace is slow to start**

The first build downloads the Swift Docker image (~1 GB). Subsequent starts are much faster because the image is cached.

**Changes not showing in the browser**

The server must be restarted after every code change:

```bash
Ctrl + C
./build.sh
./run.sh
```

---

## Tech Stack

- Swift 6.2
- Hummingbird 2 (web server)
- SQLite.swift (database access)
- Pico CSS (minimal HTML styling)
- GitHub Codespaces (development environment)
