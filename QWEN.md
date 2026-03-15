# QWEN.md — ZeroClaw Context

## Project Overview

**ZeroClaw** ist ein autonomes AI-Agent-Runtime-System, geschrieben in Rust. Es ist optimiert für minimale Ressourcennutzung (<5MB RAM, <10ms Cold Start), maximale Portabilität und vollständige Austauschbarkeit aller Komponenten.

### Kernprinzipien

- **Zero Overhead:** Minimaler Footprint durch Rust-first Architektur
- **Zero Compromise:** Vollständige Funktionalität trotz kleiner Größe
- **100% Rust:** Keine Runtime-Abhängigkeiten (kein Node.js, Python, etc.)
- **100% Agnostisch:** Austauschbare Provider, Channels, Tools, Memory-Backends

### Architektur

Das System ist **trait-driven** aufgebaut. Jede Subsystem-Komponente ist als Rust-Trait definiert:

| Subsystem         | Trait             | Erweiterungspunkt                          |
|-------------------|-------------------|--------------------------------------------|
| AI Models         | `Provider`        | `src/providers/traits.rs`                  |
| Channels          | `Channel`         | `src/channels/traits.rs`                   |
| Tools             | `Tool`            | `src/tools/traits.rs`                      |
| Memory            | `Memory`          | `src/memory/traits.rs`                     |
| Observability     | `Observer`        | `src/observability/traits.rs`              |
| Runtime           | `RuntimeAdapter`  | `src/runtime/traits.rs`                    |
| Peripherals       | `Peripheral`      | `src/peripherals/traits.rs` (STM32, RPi)   |
| Security          | `SecurityPolicy`  | `src/security/`                            |

## Building and Running

### Voraussetzungen

- **Rust:** Version 1.87+ (`rustup default stable`)
- **Build Essentials:** `build-essential` + `pkg-config` (Linux), Xcode Command Line Tools (macOS)

### Build Commands

```bash
# Standard Build
cargo build

# Release Build (optimiert für Größe)
cargo build --release --locked

# Schneller Build für Entwicklung
cargo build --profile release-fast

# Tests ausführen
cargo test --locked

# Formatierung prüfen
cargo fmt --all -- --check

# Linting (strict)
cargo clippy --all-targets -- -D warnings

# Vollständige PR-Validierung
./dev/ci.sh all
```

### Wichtige Befehle

```bash
# Agent ausführen
zeroclaw agent -m "Hello, ZeroClaw!"

# Gateway starten (Webhook-Server)
zeroclaw gateway

# Daemon-Modus (autonomer Runtime)
zeroclaw daemon

# Status prüfen
zeroclaw status

# Onboarding (Erstkonfiguration)
zeroclaw onboard --api-key sk-... --provider openrouter

# Shell Completions
source <(zeroclaw completions bash)
```

### Feature Flags

```bash
# Hardware-Unterstützung (STM32, USB)
cargo build --features hardware

# Matrix E2EE Support
cargo build --features channel-matrix

# Nostr Support (default aktiv)
cargo build --features channel-nostr

# PostgreSQL Memory Backend
cargo build --features memory-postgres

# OpenTelemetry Observability
cargo build --features observability-otel

# Browser-Automation (Fantoccini)
cargo build --features browser-native

# Sandboxing (Linux Landlock)
cargo build --features sandbox-landlock

# WhatsApp Web Client
cargo build --features whatsapp-web
```

## Development Conventions

### Coding Standards

- **Rust Edition:** 2021
- **MSRV:** 1.87
- **Lizenz:** MIT OR Apache-2.0

### Clippy Allowances

Das Projekt erlaubt bestimmte Clippy-Lints bewusst (siehe `src/lib.rs`):

- `too_many_lines` — für komplexe Agent-Logik
- `module_name_repetitions` — bei modularen Strukturen
- `missing_errors_doc` — bei internen Fehlerpfaden
- `similar_names` — bei konsistenter Benennung

### Git Workflow

1. **Branch von `master`:** `git checkout -b feat/my-change`
2. **Pre-push Hook:** Aktivieren via `git config core.hooksPath .githooks`
3. **PR gegen `master`:** Kleine, fokussierte PRs (XS/S/M)
4. **Conventional Commits:** Klare, beschreibende Titel

### Risikoklassen (Risk Tiers)

| Risiko  | Scope                                      | Validierung                    |
|---------|--------------------------------------------|--------------------------------|
| **Low** | Docs, Tests, Chore                         | Leichte Checks                 |
| **Medium** | `src/**` ohne Security-Impact          | Volle Test-Suite               |
| **High** | `src/security/**`, `src/runtime/**`, `src/tools/**`, `.github/workflows/**` | Vollständige Security-Prüfung |

### Anti-Patterns

- Keine schweren Dependencies für kleine Convenience-Features
- Security-Policies nicht stillschweigend abschwächen
- Keine spekulativen Config-Keys "just in case"
- Keine formatting-only Changes mit functional Changes mischen
- Keine persönlichen Daten oder Secrets committen

## Repository Struktur

```
zeroclaw/
├── src/
│   ├── main.rs           # CLI Entry Point
│   ├── lib.rs            # Module Exports
│   ├── agent/            # Orchestrierungs-Loop
│   ├── gateway/          # Webhook/WebSocket Server
│   ├── security/         # Policy, Pairing, Secret Store
│   ├── memory/           # SQLite/Markdown Memory Backends
│   ├── providers/        # AI Model Provider
│   ├── channels/         # Telegram, Discord, Slack, etc.
│   ├── tools/            # Shell, File, Memory, Browser
│   ├── peripherals/      # STM32, RPi GPIO
│   ├── runtime/          # Runtime Adapter (Native, Docker)
│   ├── observability/    # Logging, Metrics, Tracing
│   ├── config/           # Schema + Config Loading
│   └── ...
├── crates/
│   └── robot-kit/        # Zusätzliche Krates
├── docs/                 # Dokumentation
├── dev/                  # Development Scripts
│   ├── ci.sh             # CI Pipeline
│   └── config.template.toml
├── tests/                # Integration/System Tests
├── benches/              # Benchmarks
├── scripts/              # Helper Scripts
└── .github/              # CI Workflows, Templates
```

## Testing

```bash
# Alle Tests
cargo test --locked

# Security-relevante Tests
cargo test -- security

# Component Tests
cargo test --test component

# Integration Tests
cargo test --test integration

# System Tests
cargo test --test system
```

## Dokumentation

- **Start:** [`docs/README.md`](docs/README.md)
- **CLI Reference:** [`docs/reference/cli/commands-reference.md`](docs/reference/cli/commands-reference.md)
- **Config Reference:** [`docs/reference/api/config-reference.md`](docs/reference/api/config-reference.md)
- **Security:** [`docs/security/README.md`](docs/security/README.md)
- **Hardware:** [`docs/hardware/README.md`](docs/hardware/README.md)
- **Contributing:** [`CONTRIBUTING.md`](CONTRIBUTING.md)

## Wichtige Dateien

| Datei                        | Zweck                                      |
|------------------------------|--------------------------------------------|
| `Cargo.toml`                 | Dependencies, Features, Profile            |
| `src/lib.rs`                 | Module-Definitionen, Clippy-Allowances     |
| `src/main.rs`                | CLI-Parsing, Command-Routing               |
| `CLAUDE.md`                  | Kontext für AI-Assistenten                 |
| `AGENTS.md`                  | Workflow für autonome Agents               |
| `CONTRIBUTING.md`            | Contributor Guidelines                     |
| `SECURITY.md`                | Security Policy, Reporting                 |
| `dev/ci.sh`                  | CI-Pipeline Script                         |
| `.githooks/`                 | Pre-push Hooks (fmt, clippy, test)         |

## Bekannte Issues / Besonderheiten

1. **Branch-Name:** Die Haupt-Branch ist `master` (nicht `main`)
2. **Codegen-Units:** Release-Build verwendet `codegen-units=1` für niedrigen RAM-Bedarf
3. **Feature-Flags:** Viele Features sind optional, um Binary-Größe zu minimieren
4. **Container-Security:** Docker-Image läuft als non-root (UID 65534)
