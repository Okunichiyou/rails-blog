# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Rails 8.1 blog application with Devise-based authentication (email/password and Google OAuth), ViewComponent UI architecture, and Steep/rbs-inline static typing.

## Common Commands

```bash
# Development server (with Tailwind CSS watch)
bin/dev

# Run all tests
bundle exec rails test

# Run single test file
bundle exec rails test test/path/to/test_file.rb

# Run specific test by line number
bundle exec rails test test/path/to/test_file.rb:42

# Run tests with coverage report (generates coverage/index.html)
COVERAGE=true bundle exec rails test

# Linting
bundle exec rubocop

# Type checking
bundle exec steep check

# Generate RBS type definitions (run after adding new classes)
bundle exec rake rbs:setup
```

## Architecture

### Authentication System

Uses Devise with multiple authenticatable models:

- `User::DatabaseAuthentication` - email/password auth
- `User::SnsCredential` - Google OAuth via omniauth-google-oauth2
- `User::Confirmation` - email confirmation flow

Controllers are namespaced under `user/` (e.g., `User::DatabaseAuthentication::SessionsController`).

### ViewComponent Structure

Components in `app/components/` follow a two-tier hierarchy:

- **`ui/`** - Reusable UI primitives (buttons, fields, panels)
  - Use keyword arguments for inputs
  - Accept `**html_options` for arbitrary HTML attributes
  - Use `filter_attribute` helper for validated attribute values

- **`domain/`** - Business logic components that transform ActiveRecord/API objects for UI consumption

Views in `app/views/` compose UI and Domain components directly.

Preview components at: `http://localhost:3000/rails/view_components/`

### Static Typing

Uses Steep with rbs-inline annotations. Type checking covers:

- `app/models/`
- `app/forms/`
- `app/components/`

Type definition priority (highest to lowest):

1. `sig/manual/` - hand-written definitions
2. `sig/generated/` - rbs-inline generated
3. `sig/rbs_rails/` - Rails auto-generated
4. `sig/prototype/` - untyped scaffolds

Running tests automatically generates rbs-inline type definitions.

### Design Guidelines

- Colors and typography must be defined in `app/assets/tailwind/application.css` as design tokens
- Contrast ratio must be AA minimum (AAA preferred where possible)
- Primary buttons may use AA when AAA would diminish visual meaning

## Development Flow

### After Editing Code

After editing Ruby files, run the following commands:

```bash
# Regenerate RBS type definitions
bundle exec rake rbs:setup

# Run type checking
bundle exec steep check
```

### Test-Driven Development

1. Identify test perspectives before implementation
2. Write tests first, then implement
3. C0 (statement coverage) is the minimum requirement

### Test Writing Rules

- Test suite names (class names and method names) must be written in Japanese

### Documentation Updates

- When implementation changes affect specifications documented in `docs/`, update the documentation accordingly
