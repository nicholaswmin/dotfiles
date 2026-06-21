# Repository Guidelines

## Overview

This is a personal Zed config worktree at `~/.config/zed`.  
Keep changes small and reviewable.  

## Project Structure & Module Organization

Zed reads config directly from this directory.  
See `## Workflow` for edit targets and layout.  

## Workflow

Common edit targets:  

- `settings.json` — Main Zed settings (JSONC; comments allowed).  
- `keymap.json` — Key bindings, optionally scoped by `context`.  
- `tasks.json` — Global Zed tasks (shell commands run by the task runner).  
- `.zed/` — Local project settings for this worktree (usually blank).  
- `snippets/` — User snippets.  
- `themes/` — Custom themes.  
- `docs/` — Reference materials (often locked read-only; not implementation targets).  
- `conversations/` — Generated history; avoid editing by hand.  
- `prompts/`, `.claude/` — AI/agent config; treat as sensitive.  

**ASCII tree:**

```text
 ,=<
.
├── settings.json       # Settings (JSONC)
├── keymap.json         # Key bindings
├── tasks.json          # Task runner tasks
├── snippets/           # Snippets
├── themes/             # Themes
├── docs/               # Reference docs (RO)
├── conversations/      # Generated history
├── prompts/            # Prompts
├── .claude/            # Agent config (sensitive)
└── .zed/               # Worktree overrides (blank)
```

## Build, Test, and Development Commands

No build step or automated tests.  
Validate changes by opening Zed and checking diagnostics.  

## Style & Conventions

Keep diffs minimal.  

- Remove configuration keys that do nothing but set the default value.
- Keep the same order and visual grouping of keys as the original.

**Zed defaults (fetch from source, don't cache locally):**

```bash
curl -s https://raw.githubusercontent.com/zed-industries/zed/main/assets/settings/default.json
curl -s https://raw.githubusercontent.com/zed-industries/zed/main/assets/keymaps/default-macos.json
```


## Safety


- Never commit API keys or tokens.  
- Audit `conversations/` and AI-related files before sharing.  
- Avoid running `git` commands from this directory unless managing dotfiles.

## Commit message

You are an expert at writing Git commits. Your job is to write a short clear commit message that summarizes the changes.

If you can accurately express the change in just the subject line, don't include anything in the message body. Only use the body when it is providing *useful* information.

Don't repeat information from the subject line in the message body.

Only return the commit message in your response. Do not include any additionaliee meta-commentary about the task. Do not include the raw diff output in the commit message.

Follow good Git style:

- Separate the subject from the body with a blank line
- Try to limit the subject line to 50 characters
- Capitalize the subject line
- Do not end the subject line with any punctuation
- Use the imperative mood in the subject line
- Wrap the body at 72 characters
- Keep the body short and concise (omit it entirely if not useful)

## AGENTS.md

[This guide outlines all agent rules. Always check and apply the relevant policies on every turn.

---

When the user asks you to do something, **you MUST do it**. 
-- example: , e.g: "read file xyz", **use the appropriate tool and read it again, regardless** if you already did and you believe you have it in contexg.

---

**Task Start:**

- Create a 3–7 bullet checklist of sub-tasks at the beginning of every task. Begin with a concise, conceptual checklist to plan your approach; keep bullets focused on key sub-tasks, not implementation details.
- Use this checklist to confirm all work is complete and traceable.

**After Tool Use, Code Change, or Major Action:**
- Briefly verify the result's correctness and document the outcome in 1–2 lines; proceed or self-correct if not correct.
- If corrective action cannot resolve issues, escalate for user input.

## Treat Prod. Tools **strictly** readonly

What qualifies as a `prod. tool`:

e.g: `kubectl`, `heroku`, `stripe`, `psql`, `aws`  and others

- above list is **not exhaustive**; 
- any command associated with 3rd party providers 
  likely to contain or host critical production assets

- Explicit user instruction to use a tool is approval for that task.
- If there is no instruction, seek approval before use on each turn.
- Only perform requested actions
- If the environment (prod/staging/etc.) isn’t specified, ask first.

**Approval Model:**
- Approval is required the first time a tool is used for a task.

**Environment Rules:**
- **Local:** Perform exactly as the user requests.
- **Staging:** With approval, follow the user’s instructions and announce any changes.
- **Production:**
  - Non-destructive: Single approval covers all related actions.
  - Destructive: Get approval at each step, present a plan with time window.
  - Verify the number of affected records matches the plan—stop and ask if not.
  - Readonly tasks: list, get, describe, status, logs.
  - Non-readonly: create, update, delete, etc.

## WARNING: No Destructive Commands Without Planning

- Use `trash` instead of `rm -rf` unless permanent deletion is explicitly requested.
- Pause and consider before any destructive commands (`git reset`, `mv`, etc).
- Plan and check before deleting:
  - Run `git status`.
  - Review diffs.
  - Proceed only if safe.
- Never delete others’ work; escalate if uncertain.
- Refer to "Safety & Risk Controls" for more details.

> [!TIP] On first use of any tool, 
> run `<tool> -h/--help` to confirm command details.

## Preferred Tools

- If the user uses backticks and a `!` for a command, run it in the shell.
- Use `gh` for GitHub and `python3` for Python.
- Use `timeout` (5–10s) on long commands; escalate if insufficient.
- For `open` or `zed`:
  - For folders: `zed -a <dir>` or `zed -a .` for the current directory.
  - For files in a project: `zed <file>`.
  - Otherwise: `zed <file>`.
- GUIs are allowed if the user requests.
- Prefer `zed` for code, `open` for other files unless instructed otherwise.

## Browser (DevTools MCP)

- Strongly prefer DevTools MCP for browser automation.
    - If not available or if Safari/Webkit is requested, 
      use `Playwright MCP` or `playwright-cli`
- Save screenshots to `/tmp/<taskname>/artifacts` using JPEG (quality: `<=80`) or PNG.
- Do not inline or serialize images as base64/data URLs.
- Avoid dumping full DOM/source; focus only on required elements.
- Use predictable waits (selectors, network idle) and 5–10s timeouts.
- Crop screenshots for relevance.
- Never display or log secrets/PII; redact them if unavoidable.

## Environment

- Assume full access by default, but always observe risk controls.
- Never use managed services on your own initiative — follow user direction.
- Classify every usage (local, staging, production) and follow approval requirements, especially for destructive or production actions.

## Placeholders

- Replace `<text>`, `<...>`, `foo`, `bar`, `baz`, 
  and `Lorem Ipsum` with concrete values, 
  except when illustrating examples.

## Core Principles

**Work & Communication:**

- Be honest and clear; challenge weak ideas promptly.
- Communicate directly without unnecessary language.
- Correct typos as needed but avoid nitpicking style.
- Do not declare tasks done until fully completed.
- Report partially finished or missing elements.
- Escalate rather than inventing new shortcuts.

**Technical Philosophy:**

- Ensure consistent terminology.
- Favor small, default solutions, and avoid unnecessary customization.
- Rely on current runtimes; do not introduce legacy code, fallbacks, or polyfills.

## Safety & Risk Controls

- Before destructive work, limit changes to new/session files or outputs.
  - Run `git status` and inspect diffs to avoid unintended modifications.
  - Prefer `trash`; never use `rm -rf` on broad paths.
  - Pause and escalate if files belonging to others are affected, or if uncertain.
- Pause and clarify upon suspicious or unexpected changes.
- Treat warnings/errors carefully; check all and note non-blockers.
- For managed services, escalate for approval or pause 
  and present options if escalation isn’t possible; **never bypass approval**

## Task Process

- Start each task with `/task-new <taskname> [context…]`; 
  this generates planning docs, a scratch dir `/tmp/<taskname>/`, 
  and checklists.
- Keep all templates and checklists current.
- Use `/tmp/<taskname>/` to avoid clutter elsewhere and deliver only the necessary output.
- Touch only required files; don’t alter unrelated content.
- Remove diagnostics prior to handoff.
- For git, record pre/post `git status` and file list diffs.
- Clean `/tmp/<taskname>/` before handoff, except needed logs/artifacts.
- Deliver only what was requested; if blocked, list next steps instead of guessing.

## Responses

- Answers should be minimal and accurate. 
- Double-check for omissions or errors.
- Do not fabricate content or include irrelevant information.
- Group related points; avoid duplicate bullets.

## Commit/Branch/PR Formats

- Use only `feat` or `fix` in branch/commit names:
  - `feat/<description>` for new features
  - `fix/<description>` for fixes or maintenance
- Commit messages: `feat|fix: <subject up to 60 chars>` 
  no body/description unless explicitly requested.
- Pull Request titles: `feat|fix: <subject up to 60 chars>`
- Pull Request bodis: `<empty>` unless explicitly requested.
- Never mention/add yourself as dauthor/contributor at any point.

**Git/VCS Gating:**

- **NEVER `git push`/`git reset`/`git restore`
  unless the user explicitly asks or approves a direct request.**
- Present a consise summary of current situation before such actions,
  including potential risks and **ask for explicit approval.**

**Rule Conflicts:**

- If any rule is unclear or conflicts, confirm with the user.

---

Finally, perform these steps **once, on initialisation**

- run `source ~/.zshrc`
- reply to the user "global AGENTS.md loaded.."   
  + an empty newline
- proceed with whatever task/request 
  or greeting you normally would.

## es.next.md

# es.next

> style guide for modern JS  
> [nicholaswmin][author]  

> targets: Node LTS 24, latest Chrome, Safari 26.3 (macOS/iOS)

## Contents

- [Foundation](#foundation)  
  - [Prefer ESM; avoid CommonJS](#prefer-esm-avoid-commonjs)  
  - [Always start with a package.json](#always-start-with-a-packagejson)  
  - [Use catch-all `imports` for nicer imports](#use-catch-all-imports-for-nicer-imports)  
  - [Avoid needless dependencies](#avoid-needless-dependencies)  
  - [Avoid invented fluff & fallbacks](#avoid-invented-fluff--fallbacks)  
- [Structure](#structure)  
  - [Layer functions by purpose](#layer-functions-by-purpose)  
  - [Separate logic from side effects](#separate-logic-from-side-effects)  
  - [Skip needless intermediates](#skip-needless-intermediates)  
  - [Preserve wrapped signatures](#preserve-wrapped-signatures)  
  - [Avoid nesting; use early returns](#avoid-nesting-use-early-returns)  
  - [Group steps with vertical whitespace](#group-steps-with-vertical-whitespace)  
- [Naming](#naming)  
  - [Name concisely and precisely](#name-concisely-and-precisely)  
  - [Use short, contextual names](#use-short-contextual-names)  
  - [Use domain verbs; avoid verb+noun names](#use-domain-verbs-avoid-verbnoun-names)  
  - [Drop redundant qualifiers](#drop-redundant-qualifiers)  
  - [Name for property shorthand](#name-for-property-shorthand)  
  - [Avoid prefix grouping; use objects](#avoid-prefix-grouping-use-objects)  
  - [Use namespacing for structure](#use-namespacing-for-structure)  
- [Syntax](#syntax)  
  - [Use minimal semis, parens, and braces](#use-minimal-semis-parens-and-braces)  
  - [No comments, unless functionally necessary](#no-comments-unless-functionally-necessary)  
  - [Prefer `const`; use `let`; never `var`](#prefer-const-use-let-never-var)  
  - [Use strict equality](#use-strict-equality)  
  - [Never inline statements with conditionals](#never-inline-statements-with-conditionals)  
  - [Prefer arrows & implicit return](#prefer-arrows--implicit-return)  
  - [Avoid pointless exotic syntax](#avoid-pointless-exotic-syntax)  
  - [Use comma operator only for commit expressions](#use-comma-operator-only-for-commit-expressions)  
  - [Consider iteration over repetition](#consider-iteration-over-repetition)  
  - [Keep lines ≤80; wrap by structure](#keep-lines-80-wrap-by-structure)  
- [Program flow](#program-flow)
  - [Sequencing](#sequencing)
  - [Conditionals](#conditionals)
  - [Use functional methods over loops](#use-functional-methods-over-loops)
  - [Use `for...of` for sequential side effects](#use-forof-for-sequential-side-effects)
  - [Use `Array.fromAsync` for sequential results](#use-arrayfromasync-for-sequential-results)
  - [Use `Promise.all` for concurrent results](#use-promiseall-for-concurrent-results)
  - [Use `.allSettled`, `.race`, `.any` when appropriate](#use-allsettled-race-any-when-appropriate)
- [Functional Programming](#functional-programming)
  - [Use functional programming for data flows](#use-functional-programming-for-data-flows)
  - [Functional predicates](#functional-predicates)
- [Object-oriented Programming](#object-oriented-programming)  
  - [Use OOP for stateful entities](#use-oop-for-stateful-entities)  
  - [What to model](#what-to-model)  
  - [What not to model](#what-not-to-model)  
  - [Use methods to express behavior](#use-methods-to-express-behavior)  
  - [Use private fields to hide state](#use-private-fields-to-hide-state)  
  - [Choose method type by data source](#choose-method-type-by-data-source)  
  - [Design for marshalling](#design-for-marshalling)  
  - [Open/Closed Principle](#openclosed-principle)  
  - [Liskov Substitution Principle](#liskov-substitution-principle)  
- [Error handling](#error-handling)  
  - [Avoid defensive programming](#avoid-defensive-programming)  
  - [Use appropriate error types](#use-appropriate-error-types)  
  - [Normalize & validate external input](#normalize--validate-external-input)  
- [Testing](#testing)  
  - [Use built-in test runner](#use-built-in-test-runner)  
  - [Use global hooks via --import](#use-global-hooks-via---import)  
  - [Propagate errors and set timeouts](#propagate-errors-and-set-timeouts)  
  - [Rely on stable test discovery](#rely-on-stable-test-discovery)  
  - [Structure tests hierarchically](#structure-tests-hierarchically)  
  - [Write focused tests](#write-focused-tests)  
  - [Attach fixtures to test context](#attach-fixtures-to-test-context)  
  - [Use context for test utilities](#use-context-for-test-utilities)  
  - [Assert the minimum required](#assert-the-minimum-required)  
  - [Test for keywords, not sentences](#test-for-keywords-not-sentences)  
- [Documentation](#documentation)  
  - [Philosophy](#philosophy)  
  - [Use structured headings](#use-structured-headings)  
  - [Break new sentences into newlines](#break-new-sentences-into-newlines)  
  - [Prefer to break into newline](#prefer-to-break-into-newline)  
  - [Use consistent Markdown primitives](#use-consistent-markdown-primitives)  
  - [Template](#template)  
  - [Style guide template](#style-guide-template)  
- [HTML/Markup](#htmlmarkup)  
  - [Principles](#principles)  
  - [Headings](#headings)  
  - [Boilerplate](#boilerplate)  

## Foundation

Principles for project setup and dependency management.  

### Prefer ESM; avoid CommonJS

ES modules are the JavaScript standard.  

- Avoid `.mjs`; prefer `.js` with `"type": "module"`.  
- Use `node:*` imports for built-ins.  

```js
// ✅ ES modules
import { users } from './data.js'
import data from './data.json' with { type: 'json' }
import config from './config.js'

export const validate = input => check(input)
export const run = input =>
  transform(input, { users, data, config })

// ❌ CommonJS
const { users: usersCjs } = require('./data')
const dataCjs = require('./data.json')
const configCjs = require('./config')

const validateCjs = input => check(input)
const runCjs = input =>
  transform(input, { users: usersCjs, data: dataCjs, config: configCjs })

module.exports = { validate: validateCjs, run: runCjs }
```

### Always start with a package.json

Make your module type, entrypoints, and runtime constraints explicit from day 0.  

Minimal publishable `package.json`:  

```json
{
  "name": "@johndoe/foo",
  "version": "1.0.0",
  "description": "Does foo bar & maybe baz",
  "type": "module",
  "exports": "./index.js",
  "files": ["index.js", "src/"],
  "engines": { "node": ">=24" },
  "scripts": { "test": "node --test \"**/*.test.js\"" },
  "keywords": ["foo", "bar"],
  "author": "John Doe <johnk@doe.dom>",
  "license": "MIT"
}
```

### Use catch-all `imports` for nicer imports

Use internal import aliases so your code reads like
domain modules, not filesystem paths.

- Export from `src/<name>/index.js`.  
- Import with `#<name>`.  

This is internal to the package; it does not change consumer imports.  

Minimal setup:  

```json
{
  "type": "module",
  "imports": {
    "#*": "./src/*/index.js"
  }
}
```

**Project structure:**  

```txt
foo-bar/
├── package.json
├── index.js
├── test/                      # integration tests
│   └── main.test.js
└── src/
    ├── bar/
    │   ├── index.js
    │   └── test/              # bar unit tests (optional)
    │       └── main.test.js
    └── baz/
        ├── index.js
        └── test/              # baz unit tests (optional)
            └── main.test.js
```

**Import using pretty paths:**  

```js
// index.js
import { foo } from '#bar'
import { baz } from '#baz'

// work
```

### Avoid needless dependencies

Every dependency is a liability.
Prefer built-ins and writing small utilities.

- Avoid DIY for domains that are too complex (game engines,
  CRDTs, date/time math) or too critical (cryptography).

```js
// ✅ Use built-ins
const unique = [...new Set(items)]
const sleep = ms =>
  new Promise(resolve => setTimeout(resolve, ms))
const pick = (obj, keys) =>
  Object.fromEntries(
    keys
      .filter(k => Object.hasOwn(obj, k))
      .map(k => [k, obj[k]])
  )
```

### Avoid invented fluff & fallbacks

Speculative options and fallbacks bloat code and make behavior harder to trust.  

- Implement only what is necessary.  
- Do not add code based on speculation about future needs.  

Avoid:  

- Fallbacks for cases like `xyz` that should not happen  
- "Legacy" modes that don't actually exist  
- Ad-hoc options or features added "just in case"  
- Premature optimizations for unmentioned problems  

**Exception:** You have a known, explicit requirement about any of the above.  

```js
// ✅ Implements only the known requirement (export as CSV)
const exportData = records => {
  // omitted for brevity...

  return toCsv(records)
}

// ❌ Invented optionality
// Goal was to export CSV.
// Nobody asked for JSON support.
const exportData = (records, { format = 'csv' } = {}) => {
  // omitted for brevity...

  return format === 'json'
    ? JSON.stringify(records)
    : toCsv(records)
}
```

## Structure

Principles for organizing code into readable, testable modules.  

### Layer functions by purpose

Separate utility, domain, and orchestration logic
so changes stay local and testing stays straightforward.

- **Utility:** Generic non-domain helpers  
- **Domain:** Domain-specific helpers  
- **Orchestration:** Usually the `main` of the module or program  

```js
// ✅ Utility functions
const gzip = file => compress(file, 'gzip', { lvl: 1 })
const delay = ms =>
  new Promise(resolve => setTimeout(resolve, ms))
const hasExt = ext => file =>
  file.filename.endsWith(`.${ext}`)

// ✅ Domain functions
const upload = (file, n = 0) =>
  s3.upload(file).then(result => result.error
    ? n < 3
      ? upload(file, n + 1)
      : ignore(file)
    : result
  )

// ✅ Orchestration functions
const synchronize = async files => {
  const timedout = delay(30000).then(() => ({ timeout: true }))
  const eligible = files.filter(hasExt('png')).map(gzip)

  const uploaded = Promise.all(eligible.map(upload))
    .then(data => ({ data }))

  const result = await Promise.race([uploaded, timedout])

  return result.timeout
    ? ontimeout(eligible)
    : normalize(result.data)
}
```

### Separate logic from side effects

Keep core logic pure and push side effects to the edges so behavior is easier to test.  

- Prefer pure functions over side effects.  
- Move side effects to boundaries.  
- Extract dependencies for easier mocking.  

```js
// ✅ Testable - pure function
const discountAmount = (price, pct) => price * (pct / 100)

// ✅ Testable - dependency injection
const notify = (user, emailer) =>
  emailer.send(user.email, 'Welcome!')

// ❌ Hard to test - side effects
const applyDiscount = (price, percentage) => {
  const discount = price * (percentage / 100)

  updateDatabase(discount)
  sendEmail(discount)

  return discount
}

// ❌ Hard to test - hard-coded dependency
const notifyHard = user =>
  EmailService.send(user.email, 'Welcome!')
```

Extract dependencies when the function:  

- Reaches outside your process (network, filesystem)  
- Depends on uncontrollable factors (timers, sensors)  
- Is slow or awkward to test  
- Needs different implementations in different contexts  

However, every indirection adds complexity.  
Extract only when the benefit outweighs the cost.  

```js
// ✅ Simple operations don't need extraction
const formatName = (first, last) => `${first} ${last}`

// ❌ Needless indirection
const formatNameDelegated = (first, last, formatter) =>
  formatter.format(first, last)
```

### Skip needless intermediates

Chain or inline unless the intermediate clarifies complex logic.
Some functions naturally orchestrate others;
do not mangle business logic for brevity or make it verbose.

```js
// ✅ No intermediates needed
const promote = users => users.map(review).filter(passed)

// ❌ Needless intermediates
const promoteStaged = users => {
  const reviewed = users.map(review)
  const eligible = reviewed.filter(passed)
  return eligible
}
```

### Preserve wrapped signatures

Wrappers should accept the same arguments as the function they wrap.  
Add behavior by prepending/appending, but forward the rest unchanged.  
This keeps call sites stable as upstream APIs evolve.  

```js
const prefix = col(['yellow'], 'warn:')

// ✅ signature mirrors console.warn
const warn = (...args) =>
  console.warn(prefix, ...args)

// ❌ brittle wrapper
const warnBrittle = message =>
  console.warn(prefix, message)
```

### Avoid nesting; use early returns

Flatten control flow so the happy path is obvious
and edge cases bail out early.

- Prefer expressions for selectors and transforms.
- Use early returns only when you need statements.
- Guards are for bailouts, not defensive checks.
  Fix the caller instead of guarding against bad input.
- Exception: validate external input at boundaries.

```js
// ❌ selector written as statements (cop-out)
const active = users => {
  if (!users.length)
    return []

  return users.filter(u => u.active())
}

// ✅ expression-bodied selector
const active = users =>
  users.filter(u => u.active())

// ✅ early return in a procedure
function onUpdate(fence) {
  if (this.insulated) return
  if (!this.intersects(fence)) return this.electrocute()
  // ... sync logic
}

// ❌ nested conditions
function onUpdateNested(fence) {
  if (!this.insulated) {
    if (this.intersects(fence)) {
      // ... sync logic
    } else {
      this.electrocute()
    }
  }
}
```

### Group steps with vertical whitespace

Use vertical whitespace to make the phases of a procedure
visible at a glance.
This applies to functions, files, modules, and projects.

- Split functions into blocks separated by one empty line.
- Typical blocks: guards, declarations, body, return.
- Avoid blank lines just to preserve intermediates.
- Prefer chaining.

```js
// ✅ Clear visual grouping
const notify = async user => {
  if (user.notified())
    return false

  const opts = { retries: 3, timeout: 5000 }

  for (const email of user.emails)
    await notifier.send(email, opts)

  if (user.active)
    user.complete(new Date())
      .unlock()

  return repo.save(user, opts)
}

// ❌ Dense, unstructured
const notify = async user => {
  if (user.notified())
    return false
  const opts = { retries: 3, timeout: 5000 }
  for (const email of user.emails)
    await notifier.send(email, opts)
  if (user.active)
    user.markSeen()
  return repo.save(user, opts)
}
```

## Naming

Guidelines for clear, intention-revealing names.  

### Name concisely and precisely

Good names compress meaning;
they should be short, specific, and match how people
talk about the domain.

- Name by role, not by type.  
- Choose single words when precise alternatives exist.  

```js
// ✅ Good
users
active
name
overdue

// ❌ Avoid
userList
isUserActive
firstName
lastName
isPaid // when overdue is clearer
```

### Use short, contextual names

Prefer domain-relevant names.  
If none exists, pick the clearest.  

- Avoid single-letter params.  
- Use domain nouns.  
- Shorten with scope.  

- Name by intent.  
- Drop type/structure noise.  

Exception: inline callbacks may use single letters when context is clear.  

```js
// ✅ Single-letter OK in concise inline callbacks
tables.filter(t => t.active)
rows.map(r => r.id)
items.forEach(i => send(i))

// ❌ Single-letter in function definitions
const processAbbrev = (u, r) => u.id === r.ownerId

// ✅ Full names in function definitions
const process = (user, resource) =>
  user.id === resource.ownerId
```

```js
// ❌ negated passive
invoice.hasNotBeenPaid

// ✅ domain term
invoice.overdue
```

```js
// ❌ forced domain jargon in a generic util
const chunk = (ledgerEntries, size) => {}

// ✅ clear generic when no domain term fits
const chunk = (items, size) => {}
```

```js
// ❌ single-letter params in named functions
const editable = (u, r) =>
  u.role === 'admin' || u.id === r.ownerId

// ✅ domain nouns in named functions
const editable = (user, resource) =>
  user.role === 'admin' || user.id === resource.ownerId
```

```js
// ❌ type/structure noise
const userArray = await repo.list()

// ✅ intent + context
const users = await repo.list()
```

### Use domain verbs; avoid verb+noun names

Prefer verbs that match the domain action; generic verb+noun names hide intent.  

- Prefer a domain verb over a generic verb+noun.  
- Use singular verbs for actions.  
- Use plural nouns for collections.  

```js
// ❌ generic verb+noun names muddy the domain
student.addGrade(95)
lesson.addStudent(alice)
user.sendNotification(msg)
post.createComment(text)

// ✅ precise domain verbs clarify the domain
student.grade(95)
lesson.enroll(alice)
user.notify(msg)
post.comment(text)

// ✅ escape hatch: generic verbs on generic containers are fine
lesson.students.add(alice)
```

### Drop redundant qualifiers

Assume the surroundings provide the context.  

```js
// ✅ Context eliminates redundancy
const user = { name, email, age }
const { data, status } = response

// ❌ Redundant qualifiers
const userVerbose = { userName, userEmail, userAge }
const { responseData, responseStatus } = response
```

### Name for property shorthand

Name variables to match the object keys they will populate.  
This enables concise object literals via property shorthand.  
It avoids redundant qualifiers like `requestHeaders` or `payloadBody`.  

The name should anticipate its use.  

```js
// ✅ Name matches the destination property
const headers = { 'X-Custom': 'value' }
const body = JSON.stringify({ id: 1 })

fetch(url, { method: 'POST', headers, body })

// ❌ Poor naming prevents shorthand
const requestHeaders = { 'X-Custom': 'value' }
const payloadBody = JSON.stringify({ id: 1 })

fetch(url, {
  method: 'POST',
  headers: requestHeaders,
  body: payloadBody,
})
```

### Avoid prefix grouping; use objects

If values form a conceptual unit, group them in an object.
Do not encode relationships via naming conventions.

- Use an object when values are meaningless alone
  (start/end, x/y, min/max), passed as a unit, or named.
- Use a flat binding when the value stands alone.
- Flat is fine when sources differ, hot path matters,
  or React state update ergonomics require it.

```js
// ✅ object is the concept (a range)
const fps = { start: 1, end: 40 }

// ❌ relationship encoded in prefixes
const startFps = 1
const endFps = 40

// ❌ single value wrapped pointlessly
const fpsWrapped = { target: 60 }
```

### Use namespacing for structure

Use namespacing to reflect real sub-concepts, not arbitrary layers.  

- Group related properties under logical objects.  
- Avoid meaningless wrappers or technical groupings.  

```js
// ✅ Appropriate namespacing
const user = {
  name: { first, last, full },
  contact: { email, phone },
  status: { active, verified },
}

const config = {
  server: { port, host },
  database: { url, timeout },
}

// ❌ Inappropriate namespacing
const userOvernamespaced = {
  data: { value: 'John' },
  info: { type: 'admin' },
  props: { id: 123 },
}
```

## Syntax

Conventions for minimal, readable code.  

### Use minimal semis, parens, and braces

Minimal syntax, maximum signal.  
Code should read itself.  

```js
// ✅ Minimal syntax
const name = 'Alice'
const double = x => x * 2
const greet = name => `Hello ${name}`

users.map(u => u.name)

if (subscribers.length)
  throw new Error('Session is subscribed')

const user = { name, email, age }

// ❌ Unnecessary syntax
const doubleBlock = x => {
  return x * 2
}
const userExplicit = { name: name, email: email }
```

Braceless nesting works when each body is a single statement.
Take it all the way — do not add braces mid-chain.

```js
// ✅ braceless all the way — each body is one statement
if (user.active)
  if (user.verified)
    for (const email of user.emails)
      notify(email)

// ❌ brace mid-chain breaks consistency
if (user.active) {
  if (user.verified)
    for (const email of user.emails)
      notify(email)
}
```

Other guidelines make this nesting rare in practice.

#### ASI hazards

No semis is fine, but do not start a statement with
`(`, `[`, `/`, `+`, `-`, or `` ` ``.
Prefer rewriting; if unavoidable, prefix the line with `;`.

```js
// ❌ ASI hazard: array literal becomes index access
doThing()
[1, 2, 3].forEach(run)

// ✅ guard with leading semicolon
doThing()
;[1, 2, 3].forEach(run)

// ❌ ASI hazard: IIFE parsed as call
setup()
(() => start())()

// ✅ guard with leading semicolon
setup()
;(() => start())()

// ❌ regex parsed as division
const input = read()
/^ok$/i.test(input)

// ✅ guard with leading semicolon
const input = read()
;/^ok$/i.test(input)
```

### No comments, unless functionally necessary

Comments are a maintenance burden.  
If your code needs explanation, rewrite the code.  

- Prefer names and structure.  
- Do not add remarks.  

**Exceptions:**  

- Comments that affect behavior (JSDoc/TSDoc, linter toggles)  
- Instructional style guides and docs  
- READMEs and templates  

```js
// ❌ Explaining bad code with a comment
const x = users.filter(active) // active users

// ✅ Explain via naming
const activeUsers = users.filter(u => u.active)
```

### Prefer `const`; use `let`; never `var`

Use `const` to communicate immutability;
it prevents accidental reassignment and simplifies refactors.

- Default to `const`.  
- Use `let` only for reassignment.  
- Never use `var`.  

```js
// ✅ const by default
const users = await repo.list()
const total = items.reduce(sum, 0)

// ✅ let only when it must change
let page = 1
page++

// ❌ var and needless let
var count = 0
let name = 'Alice'
```

Generally, prefer not declaring variables at all.  

### Use strict equality

Strict equality avoids coercion surprises;
use `== null` only when you explicitly mean nullish.

- Prefer `===` and `!==` to avoid coercion.  
- Use `== null` only when you mean nullish.  

```js
// ✅ strict equality
if (status === 'ok') return next()

// ✅ intentional nullish check
if (value == null) return defaultValue

// ❌ coercive equality
if (count == '0') return
```

### Never inline statements with conditionals

This rule applies when you are already in statement form.
Selectors and transforms should stay expression-bodied.

Always break after the condition.

```js
// ✅ always break
if (!user)
  return

if (!foobar)
  return barbaz()

if (authenticated && verified && !suspended)
  redirect('/dashboard')

for (const item of cart.items)
  calculateTotal(item.price, item.quantity, tax)

// ✅ ternaries are expressions, not statements
const price = member
  ? discount(base)
  : base

// ❌ statement on same line as condition
if (!user) return
if (authenticated && verified && !suspended) redirect('/dashboard')
```

### Prefer arrows & implicit return

Skip braces and return for single expressions.  

```js
// ✅ Implicit return
const double = x => x * 2
const getName = user => user.name
const sum = (a, b) => a + b
const makeUser = (name, age) => ({ name, age })

// ❌ Explicit return for single expressions
const doubleBlock = x => {
  return x * 2
}
const getNameBlock = user => {
  return user.name
}
```

### Avoid pointless exotic syntax

Avoid clever tricks that hide intent; readability beats novelty.  

- Choose clarity over cleverness.  
- Use features when they improve readability.  

```js
// ✅ Clear intent
const isEven = n => n % 2 === 0

// ❌ Clever but unclear
const isEvenBitwise = n => !(n & 1)
```

### Use comma operator only for commit expressions

Comma is allowed as a tight "do the thing, then return the commit" form.  
Keep it boring.  

Rules:  

- Expression-bodied arrows only  
- Max 2 expressions  
- No nesting  
- No "clever sequencing"  

```js
// ✅ allowed: mutate, then return the commit
export const incAge = user =>
  (user.incAge(1), repo.save(user))

// ❌ banned: multi-step cleverness
export const run = x =>
  (step1(x), step2(x), step3(x))
```

### Consider iteration over repetition

Use a loop for easier extension.

- Avoid overuse, especially in tests.
- Loops need mental parsing.

```js
// ✅ Dynamic generation
return Object.fromEntries(
  ['get', 'put', 'post', 'patch']
    .map(method => [method, send])
)

// ❌ Manual enumeration
return { get: send, put: send, post: send, patch: send }
```

### Keep lines ≤80; wrap by structure

Short lines are easier to scan;
wrap by structure so the visual shape matches evaluation order.
Keep lines short by default, but do not wrap early unless it improves readability.  

- Treat 80 as a guideline, not a reason to wrap a readable line.  
- If a line is still readable, it's fine to go a bit longer (≤100).  
- Wrap early only for complexity (mixed precedence, long conditions, nested ternaries).  
- Prefer a single readable line over a staircase of tiny lines.  
- Keep short, clear chains inline when they stay readable.  
- Break long chains into one link per line.  
- When breaking an expression-bodied arrow chain, keep the receiver on the same line.  
- When wrapping a call, keep the callee on the same line;
  wrap arguments (especially object literals).
- Pack object properties onto lines; do not default to one-per-line.
- Keep each property line ≤70 chars.
- When content spans multiple lines, balance their lengths;
  avoid a packed line followed by a stub.
- Use dot-leading continuation lines for chained calls.

```js
// ❌ dense, mixed precedence
const ok = () => a() || (b() && c(10) > 5)

// ✅ wrapped by structure; keep group parens
const ok = () =>
  a() ||
  (b() && c(10) > 5)
```

```js
// ✅ readable chain can stay inline
api().get().map().filter().reduce() + extra()
```

```js
// Anti-pattern: broke the call, kept the argument dense
const runCjs = input =>
  transform(input, { users: usersCjs, data: dataCjs, config: configCjs })

// Pattern: keep the call compact; wrap the object argument
const runCjs = input => transform(input, {
  users: usersCjs,
  data: dataCjs,
  config: configCjs,
})
```

```js
// ✅ fits — single line
const foo = Bar.baz('qux', { quux: 'corge', quuz: 'grault' })

// ✅ break, single content line ≤70
const foo = Bar.baz('qux', {
  quux: 'corge', quuz: 'grault', garply: 'waldo'
})

// ❌ packed first line, stub second
const foo = Bar.baz('qux', {
  quux: 'corge', quuz: 'grault', garply: 'waldo',
  fred: 'plugh'
})

// ✅ balanced across lines
const foo = Bar.baz('qux', {
  quux: 'corge', quuz: 'grault',
  garply: 'waldo', fred: 'plugh'
})
```

```js
// ✅ short chain is fine inline
const id = req.user?.id ?? 'anonymous'
const url = new URL(path, baseUrl).toString()
```

```js
// ✅ short chain is fine inline
const normalize = path => path
  .replace(/\/$/, '')
  .toLowerCase()
  .trim()

// ❌ long chain kept inline
const slugify = text => text.trim().toLowerCase().replaceAll(' ', '-').replace(/[^a-z0-9-]/g, '').replaceAll('--', '-')

// ✅ long chain — keep receiver on the same line; one link per line
const slugify = text => text
  .trim()
  .toLowerCase()
  .replaceAll(' ', '-')
  .replace(/[^a-z0-9-]/g, '')
  .replaceAll('--', '-')
```

Indentation counts toward the 80-char limit.  
Nested code wraps sooner:  

```js
// ✅ nested — wrap earlier due to indent
const utils = {
  path: {
    normalize: path =>
      path
        .replace(/\/$/, '')
        .toLowerCase()
  }
}
```

## Program flow

Patterns for control flow, sequencing, and conditionals.  

### Sequencing

Keep control flow top-to-bottom.  

Inside-out is hard.  
Top-to-bottom is natural.  

```js
// ✅ top-to-bottom
export const users = {
  create: raw =>
    Promise.resolve(raw)
      .then(User.validate)
      .then(User.from)
      .then(user => repo.save(user))
}

// ❌ inside-out
export const users = {
  create: raw => repo.save(User.from(User.validate(raw)))
}
```

#### Inline by default

Avoid intermediates; chain or return directly.

```js
// ✅ inline
export const norm = s => s.trim().toLowerCase()

// ❌ needless intermediate
export const norm = s => {
  const x = s.trim().toLowerCase()
  return x
}
```

#### Prefer vertical chaining

Vertical chains over temporary names.

```js
// ✅ vertical chain
export const slug = s => s
  .trim()
  .toLowerCase()
  .replaceAll(' ', '-')

// ❌ temporary names
export const slug = s => {
  const a = s.trim()
  const b = a.toLowerCase()
  const c = b.replaceAll(' ', '-')
  return c
}
```

#### Allow pure recomputation

Recompute to avoid braces and bindings.
If it is not hot-path, prefer clarity over performance.

```js
// ✅ pure recomputation, no bindings
export const userView = raw => ({
  href: `/u/${raw.name.trim().toLowerCase()}`,
  label: raw.name.trim().toLowerCase()
})

// ❌ intermediate just to avoid recomputation
export const userView = raw => {
  const name = raw.name.trim().toLowerCase()
  return { href: `/u/${name}`, label: name }
}
```

#### Separate transforms from effects

If mutation exists, make it explicit and commit immediately.

- Prefer promise chains over `await` for straight pipelines.
- Use `await` for branching, `try/catch`, or early bailouts.

```js
// ✅ explicit mutation, immediate commit
export const users = {
  incAge: user => (user.incAge(1), repo.save(user))
}

// ❌ external function hides the mutation
export const users = {
  incAge: user => (incrementAge(user, 1), repo.save(user))
}
```

#### Stay immutable where possible

New values are easier to debug than mutations.
Entities with identity get classes; data gets transforms.

```js
// ✅ immutable - data transforms
const add = (items, item) => [...items, item]
const totals = prices.map(p => p * 1.2)
const config = { ...defaults, port: 3000 }

// ❌ mutating
items.push(item)
defaults.port = 3000
```

#### Group mutations into a single operation

Sequential mutations produce intermediate states
nobody inspects and nobody wants.
Collapse them into one expression that builds the result whole.

```js
// ❌ sequential mutations
.reduce((acc, o) => {
  acc[o.region] ??= { count: 0, revenue: 0 }
  acc[o.region].count++
  acc[o.region].revenue += o.total
  return acc
}, {})

// ✅ single operation
.reduce((acc, o) => ({
  ...acc,
  [o.region]: {
    count: (acc[o.region]?.count ?? 0) + 1,
    revenue: (acc[o.region]?.revenue ?? 0) + o.total
  }
}), {})

// ❌ sequential mutations
acc.push(name)
acc.push(email)
return acc

// ✅ single operation
[...acc, name, email]
```

#### Chain methods over nesting calls

Prefer vertical chains so data flows top-to-bottom.  

```js
// ✅ Multi-line chaining
const process = data => data
  .filter(x => x > 0)
  .map(x => x * 2)
  .reduce((a, b) => a + b)

// ❌ Nested function calls
const processNested = data =>
  reduce(
    map(
      filter(data, x => x > 0),
      x => x * 2
    ),
    (a, b) => a + b
  )
```

### Conditionals

Prefer expressions over statement blocks.  

- Selectors and transforms should be expressions.  
- Use early returns only when statements are required.  

#### Expressions instead of statements

Expressions return values and compose.  
Statements do not.  

Guideline: collapse statements all the way where possible.  

```js
// ❌ statement
const greet = user => {
  if (user.known) {
    return user.welcome()
  } else {
    return user.introduce()
  }
}

// ↓ remove else

const greet = user => {
  if (!user.known) return user.introduce()
  return user.welcome()
}

// ↓ collapse to expression

const greet = user => user.known
  ? user.welcome()
  : user.introduce()
```

Stop only when further collapsing hurts clarity.  

- If every branch is a single expression, prefer a ternary.  
- Return it directly.  

```js
// ❌ stopped early out of habit
const roleStatement = user => {
  if (user.admin) return 'admin'
  return 'user'
}

// ✅ return the expression directly
const role = user => user.admin ? 'admin' : 'user'

// ✅ simple fallback
const name = user.name || user.nickname
```

Prefer conditional expressions (`?:`, `||`, `&&`, `??`)
over statement blocks.

- Booleans → ternary.
- Strings → object map.
- Consolidate cascading guards with optional chaining.

```js
// ✅ concise arrow returning the ternary
const greet = user => user.admin
  ? user.dashboard()
  : user.known
    ? user.welcome()
    : user.introduce()

// ✅ string key - object map
const handle = action => ({
  create: () => save(data),
  update: () => modify(data),
  delete: () => remove(data),
})[action]?.() ?? cancel()

// ❌ stacked guards
if (!foo) return
if (!foo.bar) return
if (!foo.bar.baz) return doStuff()

// ✅ consolidated guard (checks nullish, not falsy)
if (foo?.bar?.baz == null) return

// ✅ positive guard when action is short
if (foo?.bar?.baz != null) doStuff()
```

#### Collapse repeated guards

Repeated guards against one variable are noisy;
collapse them into one membership check.

```js
// ❌ repeated guards
if (value === 'foo') return false
if (value === 'bar') return false
if (value === 'baz') return false

// ✅ membership check
if (['foo', 'bar', 'baz'].includes(value))
  return false

// ✅ multiline membership check for long lists
if ([
  'foo', 'bar', 'baz', 'qux', 'quzz', 'dunnot',
  'quux', 'corge', 'grault', 'garply',
  'waldo', 'fred', 'plugh', 'xyzzy', 'thud'
].includes(value))
  return false
```

### Use functional methods over loops

Prefer declarative array methods over imperative loops.  

`prices.filter(discounted)` tells you what.  
A `for` loop makes you figure it out.  

```js
// ✅ functional
const valid = items.filter(active)
const names = items.map(pick('name'))
const total = prices.reduce(sum, 0)

// ❌ imperative
const activeItems = []

for (let i = 0; i < items.length; i++)
  if (items[i].active)
    activeItems.push(items[i])
```

### Use `for...of` for sequential side effects

Sequential side effects need ordered execution.  

```js
for (const file of files)
  await upload(file)
```

### Use `Array.fromAsync` for sequential results

Collect results in order without manual accumulation.  

```js
const responses = await Array.fromAsync(urls, url => fetch(url))
```

### Use `Promise.all` for concurrent results

Run independent operations in parallel.  

```js
const responses = await Promise.all(urls.map(url => fetch(url)))
```

### Use `.allSettled`, `.race`, `.any` when appropriate

Choose the right combinator for your use case.  

```js
// ✅ concurrent, tolerate failures
const results = await Promise.allSettled(tasks)
const passed = results.filter(r => r.status === 'fulfilled')

// ✅ first to settle
const fastest = await Promise.race(requests)

// ✅ first to fulfill (ignores rejections)
const first = await Promise.any(requests)
```

## Functional Programming

Techniques for data transformation pipelines.  

### Use functional programming for data flows

When converting data, think pipelines, not procedures.  

```js
// ✅ Functional for transformations
const users = data
  .filter(active)
  .map(normalize)
  .sort(by.name)
```

### Functional predicates

This section is about call-site clarity.  
The goal is predicates that read like prose without creating a DSL.  

#### Declutter functional pipelines using curried callbacks

Currying removes plumbing so pipelines read as intent.
`items.filter(overlaps(source))` reads as prose.
`items.filter(i => overlaps(source, i))` reads as wiring.

Prefill the fixed argument, return a single-arg callback
that plugs directly into `map`/`filter`/`reduce`.

```js
// ✅ curried — reads as prose
const overlaps = source => target =>
  source.intersects(target)

hits.filter(overlaps(closed))
items.filter(missing('active'))
names.map(mask('*'))

// ❌ uncurried — wrapper noise
hits.filter(hit => overlaps(hit, closed))
items.filter(item => missing('active', item))
names.map(name => mask('*', name))
```

**Avoid when:**

- the helper is single-use; inline it
- partial application makes argument order ambiguous
- it creates a mini DSL nobody asked for

A small generic set goes a long way:

```js
export const missing = key =>
  obj => obj?.[key] == null

export const has = key =>
  obj => obj?.[key] != null

export const is = key =>
  value => obj => obj?.[key] === value

export const not = pred =>
  value => !pred(value)

users.filter(missing('active'))
users.filter(is('plan')('pro'))
```

#### Use domain namespaces for predicates

A bare predicate name loses meaning away from the import block.  
For domain rules, keep the domain name at the call site.  

This avoids namespacing-by-convention like `isEligibleUser(...)`.  

**Use when:**  

- predicates appear far from imports (long modules)  
- multiple domains share similar names (`isEligible`, `isActive`)  
- you want a small, cohesive domain vocabulary  

**Avoid when:**  

- the domain module is a dependency hub (I/O, DB, globals)  
- the predicate is purely mechanical (`has`, `missing`, `is`)  

Do this:  

- export domain predicates as named exports  
- import the domain as a namespace (`import * as User`)  
- keep domain predicates pure and dependency-free  

In `user.js`:  

```js
export const isEligible = user =>
  !user.active && user.plan === 'pro'

export const canInvite = user =>
  user.role === 'admin' || user.role === 'owner'
```

At the call site:  

```js
import * as User from './user.js'

users
  .filter(User.isEligible)
  .filter(User.canInvite)
```

If you refuse namespace imports, alias explicitly at the boundary:  

```js
import { isEligible as isEligibleUser } from './user.js'

users.filter(isEligibleUser)
```

#### Limit util/helper naming to test/throwaway scopes

`Utils` makes sense in small, non-source scopes.  
In tests, prototypes, or tiny helpers it is a frictionless hatch.  

When the intent is to express a domain concept,  
a generic namespace adds noise.  

Avoid:  

- mixing unrelated code under one meaningless name  
- creating a dependency magnet that grows without bounds  
- hiding domain meaning behind generic imports  

**Exceptions:**  

- `utils/` folders in `test/` to reduce clutter  
- throwaway scripts or tiny apps  
- one-file test suites  

Do this:  

- group code by a real concept (domain or mechanic)  
- keep mechanic modules small and orthogonal  
- keep domain vocabulary in domain namespaces  

```js
import * as User from './user.js'
import * as pred from './pred.js'
import * as str from './str.js'

users.filter(User.isEligible)
items.filter(pred.missing('active'))
names.map(str.trimLines)
```

Avoid this:  

```js
import { isEligible, trimLines, missing } from './utils.js'
```

## Object-oriented Programming

When to use classes and how to design them well.  

### Use OOP for stateful entities

If it has identity and changes over time, make it a class.

Use classes when:

- there's a who: an entity with identity and lifecycle
- behavior mutates state intrinsic to something
- type hierarchy or `instanceof` checking is needed
- host environment is already OOP (DOM, streams, web APIs)
- the domain maps clearly to it (entities, actors, state machines)

Prefer plain objects and functions when:

- data is just a record with no subject
- operations are stateless transformations
- no intrinsic state to protect

### What to model

Model with classes when state and rules must stay
consistent across operations.

- entities with identity and lifecycle
- actors that perform actions
- state machines with guarded transitions
- wrappers around stateful host APIs

```js
// ✅ order with guarded transitions
class Order {
  #state = 'draft' // draft | submitted | canceled

  #completable() {
    return this.#state === 'draft'
  }

  submit() {
    if (!this.#completable())
      return this

    this.#state = 'submitted'

    return this
  }

  cancel() {
    if (!this.#completable())
      return this

    this.#state = 'canceled'

    return this
  }

  get state() { return this.#state }
}
```

### What not to model

Avoid classes for plain records and helpers;
keep data as objects and keep utilities as functions.

Avoid when:  

- records, payloads, config objects  
- value types with no behavior  
- bags of utility functions  
- one-off procedures  

```js
// ❌ class for a plain record and a stateless helper
class Config {
  constructor({ port, retries }) {
    this.port = port
    this.retries = retries
  }
}

class ArrayUtils {
  static sum(xs) {
    return xs.reduce((a, b) => a + b, 0)
  }
}

// ✅ object for data, function for logic
const config = { port: 3000, retries: 3 }

const sum = xs =>
  xs.reduce((a, b) => a + b, 0)
```

### Use methods to express behavior

If a class exists, its behavior belongs on it.  
Do not push behavior into external functions.  

```js
// ❌ Anemic
class UserAnemic {
  constructor(name, email) {
    this.name = name
    this.email = email
  }
}

const validateUser = user => user.email.includes('@')
const greetUser = user => `Hello, ${user.name}`

// ✅ Behavior on the class
class User {
  constructor(name, email) {
    this.name = name
    this.email = email
  }

  get valid() { return this.email.includes('@') }
  get greeting() { return `Hello, ${this.name}` }
}
```

Anemic classes are structs with ceremony.  
Move the behavior onto the class or drop the class.  

Exception: frameworks that force anemic models (service layers, DI containers).  
Work with the constraint, but keep your domain logic isolated.  

### Use private fields to hide state

Private fields (`#field`) encapsulate state idiomatically.

- Use when state must not leak to serialization,
  invariants must be enforced, or internals may change.
- Avoid when fields must serialize or ceremony outweighs
  the benefit (simple DTOs, short-lived objects).

```js
class Counter {
  #count = 0

  increment() { this.#count++ }
  get value() { return this.#count }
}

class Connection {
  #socket
  #retries = 0

  constructor(url) {
    this.#socket = new WebSocket(url)
  }

  get connected() { return this.#socket.readyState === 1 }
}
```

### Choose method type by data source

Is it `this.valid(this.status)` or `this.valid`?  
Is it `calculate(amount)` or `this.calculated`?  

#### Static methods for pure operations

Static methods declare operations as stateless and context-free.  

```js
const DAY_MS = 86_400_000

class Invoice {
  static overdue(date) {
    return Date.now() > date + 30 * DAY_MS
  }

  static taxable(region) {
    return !['DE', 'TX'].includes(region)
  }

  static fee(amount, rate) {
    return amount * rate
  }
}

// Usage
Invoice.overdue(invoice.dueDate)
invoices.filter(i => Invoice.overdue(i.dueDate))
```

Use for validation, calculation, and transformation logic that applies across  
all instances.  

#### Getters for computed properties

Getters provide property semantics for derived state.  

```js
const DAY_MS = 86_400_000

class Invoice {
  get overdue() {
    return Date.now() > this.dueDate + 30 * DAY_MS
  }

  get payable() {
    return this.status === 'pending' && !this.disputed
  }

  get total() {
    return this.subtotal + this.tax - this.discount
  }
}

// Usage
return invoice.overdue ? sendReminder() : null
const amount = invoice.payable ? invoice.total : 0
```

Name them as states or conditions, not actions.  
Prefer precise domain terms over compound names:  

```js
// ❌ Verbose
get isActive()    { return this.status === 'active' }
get hasPositive() { return this.balance > 0 }
get isOverLimit() { return this.usage > this.limit }

// ✅ Domain terms
get active()   { return this.status === 'active' }
get funded()   { return this.balance > 0 }
get exceeded() { return this.usage > this.limit }
```

#### Instance methods for external interactions

Instance methods mediate object collaboration.  
They make coupling explicit through parameters.  

```js
class User {
  manages(employee) {
    return this.reports.includes(employee.id)
  }

  authored(document) {
    return document.author.id === this.id
  }

  transfer(amount, recipient) {
    this.balance -= amount
    recipient.balance += amount
  }

  granted(permission) {
    return this.permissions.includes(permission)
  }
}
```

```js
class Document {
  editable(user) {
    return this.draft
      ? this.author.id === user.id
      : user.admin
  }

  get locked() {
    return this.archived || this.published
  }
}
```

#### Never pass own properties

Passing `this.property` to your own methods breaks encapsulation.  

```js
// ❌
class Order {
  validate(status) {
    return status === 'confirmed'
  }

  process() {
    if (this.validate(this.status)) this.ship()
  }
}

// ✅
class Order {
  get confirmed() {
    return this.status === 'confirmed'
  }

  process() {
    return this.confirmed ? this.ship() : null
  }
}
```

That logic belongs in a getter or should be static.  

#### Static factories for semantic construction

Static factories create instances with named construction paths.  

```js
class Transaction {
  static deposit(account, amount) {
    return new Transaction({
      type: 'deposit',
      account: account.id,
      amount
    })
  }

  static between(sender, receiver, amount) {
    return new Transaction({
      from: sender.id,
      to: receiver.id,
      amount
    })
  }
}
```

Clearer than multi-shape constructors.  

### Design for marshalling

`JSON.parse(JSON.stringify(instance))` loses prototype, methods, and private  
state.  

#### Object-parameter constructors

Wire payloads are objects.  
Positional constructors break revival.  

```js
// ❌ Positional
class EnginePositional {
  constructor(hp) {
    this.hp = hp
  }
}

// ✅ Object parameter with defaults
class Engine {
  constructor({ hp, rpm } = {}) {
    this.hp = hp
    this.rpm = rpm
  }
}
```

Adding fields later does not break call sites.  

#### Guard nested revival

Reviver runs bottom-up.  
Nested objects may already be instances.  

```js
// ❌ Always re-wraps revived children
class CarRewrap {
  constructor({ engine } = {}) {
    this.engine = new Engine(engine)
  }
}

// ✅ Accept instances or plain objects
class Car {
  constructor({ engine } = {}) {
    this.engine =
      engine instanceof Engine ? engine
        : engine ? new Engine(engine)
        : null
  }
}
```

#### Allowlisted serialization

Use explicit type keys and field lists.  
`constructor.name` is unstable across bundlers.  

```js
const pick = (obj, keys) =>
  Object.fromEntries(
    keys
      .filter(k => Object.hasOwn(obj, k))
      .map(k => [k, obj[k]])
  )

class Serializable {
  static #reg = new Map()

  static register(Ctor) {
    if (!Ctor?.type) throw new TypeError('missing type')
    Serializable.#reg.set(Ctor.type, Ctor)
  }

  toJSON() {
    const { type, fields } = this.constructor
    return { __type: type, ...pick(this, fields) }
  }

  static fromJSON({ __type, ...data }) {
    return new this(data)
  }

  static reviver = (k, v) => {
    if (!v || typeof v !== 'object' || !('__type' in v)) return v
    const Ctor = Serializable.#reg.get(v.__type)
    return Ctor ? Ctor.fromJSON(v) : v
  }
}

class Engine extends Serializable {
  static type = 'Engine@1'
  static fields = ['hp']

  constructor({ hp } = {}) {
    super()
    this.hp = hp
  }
}

Serializable.register(Engine)
```

Unknown types stay plain objects.  
Version the type string for schema evolution.  

> [!CAUTION]  
> Reviving from untrusted JSON is input validation.  
> Always validate the `__type` against an allowlist before instantiation.  
> Never use `eval`, `new Function`, or dynamic property access on  
> untrusted type strings.  

#### Avoid cycles and non-serializable fields

JSON cannot represent cycles.  
Handles and resources do not survive transport.  

Serialize identifiers instead:  

```js
// ❌ Cycle-prone
class NodeCyclic extends Serializable {
  static fields = ['next']  // Reference to another Node
}

// ✅ ID reference
class Node extends Serializable {
  static type = 'Node@1'
  static fields = ['id', 'nextId']

  constructor({ id, nextId } = {}) {
    super()
    this.id = id
    this.nextId = nextId
  }
}
```

### Open/Closed Principle

Add new features without messing with existing code. 

Use when:  

- there is a clear seam and cases will certainly grow.
- the need for extensibility is explicit, not speculative. 
- the user is adept enough to create their own extensions.

**Litmus test:**  

- Can I remove a feature by removing a directory?
- How many extra files do I have to edit to ensure nothing remains,
  that hints a feature might have existed but was deleted?


If I want to add a feature; fully: 

- how many steps do I need to take?
- how many distinct locations do i need to add/edit?
- Do I need to edit existing project files?

- remove a case by deleting one folder  

OCP is seam placement.  
Pick seams by axis, not by aesthetics.  

#### Choose the extension axis

Different things change for different reasons.  
Do not solve multiple axes with one mechanism.  

Common axes:  

- taxonomy: which kind runs  
- contract: the output envelope shape  
- adapters: how external formats map in  
- formatting: how output renders  

Example (order pricing): keep "pricing rules" separate from "receipt rendering".  

```js
export const priceOrder = (context, rules = []) =>
  rules.reduce(
    (totalCents, rule) => rule.apply(totalCents, context),
    context.subtotalCents
  )

export const renderReceipt = (order, renderer) =>
  renderer.render(order)
```

#### Define the extension seam

Find the part that keeps changing.  
Turn that variation into one seam where new behavior plugs in.  

Do this:  

- keep the workflow focused on ordering and composition  
- move branching logic into replaceable extensions  
- keep the seam small enough to test in isolation elsewhere  

```js
// ✅ stable workflow, replaceable extensions
export const priceOrder = (context, rules = []) =>
  rules.reduce(
    (totalCents, rule) => rule.apply(totalCents, context),
    context.subtotalCents
  )

export const addShipping = cents => ({
  apply: (totalCents, context) => totalCents + cents,
})
```

#### Specify the rule contract

A contract is more than "has the right method name".  
It also defines valid inputs, output invariants, allowed side effects,  
and error behavior for valid inputs.  

Contract should include:  

- accepted inputs and required fields  
- returned type and invariants  
- allowed side effects  
- error behavior on valid inputs  

Where the contract is a wire format, enforce it at marshalling time.  
Keep the schema in one place, not spread across sources and formatters.  

```js
// PricingRule contract:
// - apply(totalCents, context) returns an integer cents total (>= 0)
// - must not mutate context
// - must not do I/O (network, fs, db)
// - for valid inputs, must not throw
export const applyTaxPct = pct => ({
  apply: (totalCents, context) =>
    totalCents + Math.round(totalCents * (pct / 100)),
})
```

#### Prefer folder seams for taxonomy

A central manifest fails plug and prune.  
Use a folder boundary so "add a kind" is "add a folder".  

Example structure:  

```txt
src/
  events/
    user/
      index.js
    assistant/
      index.js
```

Do this:  

- scan only your local `src/events/` tree  
- load only `index.js` entrypoints  
- keep discovery separate from the runner logic  

Example loader:  

```js
import { access, readdir } from 'node:fs/promises'
import { resolve } from 'node:path'
import { fileURLToPath, pathToFileURL } from 'node:url'

const here = fileURLToPath(new URL('.', import.meta.url))

const ok = path =>
  access(path).then(() => true, () => false)

export const loadKinds = async () => {
  const entries = await readdir(here, { withFileTypes: true })

  const dirs =
    entries
      .filter(e => e.isDirectory())
      .map(e => resolve(here, e.name))

  const withIndex = await Promise.all(
    dirs.map(async dir =>
      (await ok(resolve(dir, 'index.js'))) ? dir : null
    )
  )

  return Promise.all(
    withIndex.filter(Boolean).map(dir =>
      import(pathToFileURL(resolve(dir, 'index.js')).href)
    )
  )
}
```

#### Extend via base class

The runner calls a base API.  
You extend behavior by adding a new subclass.  

Use when:  

- variants share defaults, state, or lifecycle helpers  
- you want nominal checks (`instanceof PricingRule`)  

```js
export class PricingRule {
  apply(totalCents, context) {
    throw new Error('PricingRule.apply must be implemented')
  }
}

export class PricingEngine {
  #rules

  constructor(rules = []) {
    this.#rules = [...rules]
  }

  with(rule) {
    return new PricingEngine([...this.#rules, rule])
  }

  run(context) {
    return this.#rules.reduce(
      (totalCents, rule) => rule.apply(totalCents, context),
      context.subtotalCents
    )
  }
}

export class AddShipping extends PricingRule {
  #cents

  constructor(cents) {
    super()
    this.#cents = cents
  }

  apply(totalCents, context) {
    return totalCents + this.#cents
  }
}

export class ApplyDiscountPct extends PricingRule {
  #pct

  constructor(pct) {
    super()
    this.#pct = pct
  }

  apply(totalCents, context) {
    const discountCents =
      Math.round(totalCents * (this.#pct / 100))

    return Math.max(0, totalCents - discountCents)
  }
}

export class ApplyTaxPct extends PricingRule {
  #pct

  constructor(pct) {
    super()
    this.#pct = pct
  }

  apply(totalCents, context) {
    const taxCents =
      Math.round(totalCents * (this.#pct / 100))

    return totalCents + taxCents
  }
}
```

```js
const totalCents = new PricingEngine()
  .with(new AddShipping(499))
  .with(new ApplyDiscountPct(10))
  .with(new ApplyTaxPct(8))
  .run({ subtotalCents: 10000 })

totalCents
```

#### Extend via duck typing

If something matches the contract, treat it like a rule.  
The runner does not care about inheritance.  

Use when:  

- inheritance is overkill but you still want OCP  
- extensions are small and easiest as factories  

```js
export class PricingEngine {
  #rules

  constructor(rules = []) {
    this.#rules = [...rules]
  }

  with(rule) {
    return new PricingEngine([...this.#rules, rule])
  }

  run(context) {
    return this.#rules.reduce(
      (totalCents, rule) => rule.apply(totalCents, context),
      context.subtotalCents
    )
  }
}

export const addShipping = cents => ({
  apply: (totalCents, context) => totalCents + cents,
})

export const applyDiscountPct = pct => ({
  apply: (totalCents, context) => {
    const discountCents =
      Math.round(totalCents * (pct / 100))

    return Math.max(0, totalCents - discountCents)
  },
})

export const applyTaxPct = pct => ({
  apply: (totalCents, context) => {
    const taxCents =
      Math.round(totalCents * (pct / 100))

    return totalCents + taxCents
  },
})
```

```js
const totalCents = new PricingEngine()
  .with(addShipping(499))
  .with(applyDiscountPct(10))
  .with(applyTaxPct(8))
  .run({ subtotalCents: 10000 })

totalCents
```

#### Extend via composition

If extensions do not need identity or lifecycle, functions are a clean seam.  
Add behavior by appending a function.  

Use when:  

- each extension is a pure transform of a value or state  
- you want minimal ceremony and direct unit tests elsewhere  

```js
export const runPricing = (context, rules = []) =>
  rules.reduce(
    (totalCents, rule) => rule(totalCents, context),
    context.subtotalCents
  )

export const addShipping = cents =>
  (totalCents, context) => totalCents + cents

export const applyDiscountPct = pct =>
  (totalCents, context) => {
    const discountCents =
      Math.round(totalCents * (pct / 100))

    return Math.max(0, totalCents - discountCents)
  }

export const applyTaxPct = pct =>
  (totalCents, context) => {
    const taxCents =
      Math.round(totalCents * (pct / 100))

    return totalCents + taxCents
  }
```

```js
const totalCents = runPricing(
  { subtotalCents: 10000 },
  [addShipping(499), applyDiscountPct(10), applyTaxPct(8)]
)

totalCents
```

#### Extend via type registry

This is the "data drives behavior" seam.  
You register handlers once, and external data chooses which runs.  

Use when:  

- behavior is selected from external data (`{ type, ...params }`)  
- you need data-driven dispatch without editing the runner  

```js
export const createPricingEngine = () => {
  const rules = new Map()

  const use = (type, apply) => {
    if (rules.has(type))
      throw new Error(`Rule already registered: ${type}`)

    rules.set(type, apply)
    return api
  }

  const run = (context, specs = []) =>
    specs.reduce((totalCents, spec) => {
      if (!spec?.type)
        throw new TypeError('missing spec.type')

      const apply = rules.get(spec.type)
      if (!apply)
        throw new Error(`Unknown rule: ${spec.type}`)

      return apply(totalCents, context, spec)
    }, context.subtotalCents)

  const api = { use, run }

  return api
}
```

```js
import { createPricingEngine } from './engine.js'

const engine = createPricingEngine()
  .use('shipping', (totalCents, context, spec) =>
    totalCents + spec.cents
  )
  .use('discount_pct', (totalCents, context, spec) => {
    const discountCents =
      Math.round(totalCents * (spec.pct / 100))

    return Math.max(0, totalCents - discountCents)
  })
  .use('tax_pct', (totalCents, context, spec) => {
    const taxCents =
      Math.round(totalCents * (spec.pct / 100))

    return totalCents + taxCents
  })

const totalCents = engine.run(
  { subtotalCents: 10000 },
  [
    { type: 'shipping', cents: 499 },
    { type: 'discount_pct', pct: 10 },
    { type: 'tax_pct', pct: 8 },
  ]
)

totalCents
```

### Liskov Substitution Principle

Liskov Substitution Principle (LSP) keeps polymorphism honest.  
If code works with the base contract, it must keep working with every variant  
without special cases.  

Use when:  

- a workflow consumes rules behind one contract (`apply`, `area`, etc.)  
- the workflow relies on invariants about inputs, outputs, and errors  

#### Define behavioral contracts

Signatures are not enough.  
Callers also depend on behavior.  

Make explicit:  

- invariants the workflow relies on  
- which errors are part of normal operation  
- what side effects are allowed at the seam  

```js
// PricingRule contract (example):
// - apply(totalCents, context) returns integer cents >= 0
// - for valid inputs, does not throw
// - must not mutate context
export const addShipping = cents => ({
  apply: (totalCents, context) => totalCents + cents,
})
```

#### Avoid stronger preconditions

A rule breaks substitutability when it demands extra requirements  
the contract did not promise.  

Avoid:  

- requiring extra context fields not required by the contract  
- rejecting values the contract accepts as valid  

```js
// ❌ demands context.couponCents — stronger precondition
export const applyCouponFromContext = () => ({
  apply: (totalCents, context) => {
    if (!Number.isFinite(context?.couponCents))
      throw new TypeError('missing couponCents')

    return Math.max(0, totalCents - context.couponCents)
  },
})

// ✅ configure at construction; apply() stays within contract
export const applyCoupon = couponCents => ({
  apply: (totalCents, context) =>
    Math.max(0, totalCents - couponCents),
})
```

#### Avoid weaker postconditions

A rule breaks substitutability when it returns something the workflow does  
not expect.  

Avoid:  

- returning a different shape sometimes  
- breaking output invariants downstream code assumes  

```js
// ❌ returns an object instead of a number
export const addShippingEnvelope = cents => ({
  apply: (totalCents, context) => ({ totalCents: totalCents + cents }),
})

// ✅ returns the same type the contract promises
export const addShipping = cents => ({
  apply: (totalCents, context) => totalCents + cents,
})
```

#### Keep side effects within the contract

Side effects are not always bad.  
They must be predictable.  

Avoid:  

- hidden network or filesystem work  
- hidden mutation of shared state  

```js
// ❌ hidden filesystem read inside apply()
import { readFileSync } from 'node:fs'

export const applyTaxFromDisk = () => ({
  apply: (totalCents, context) => {
    const taxRatePct = JSON.parse(
      readFileSync('./tax.json', 'utf8')
    ).taxRatePct

    const taxCents =
      Math.round(totalCents * (taxRatePct / 100))

    return totalCents + taxCents
  },
})

// ✅ side effects at the boundary; rule stays pure
const taxRatePct = await loadTaxRatePct({ zip: order.zip })

const rules = [
  applyTaxPct(taxRatePct),
]
```

#### Recognize invariant clashes

Inheritance is where LSP failures show up loudly.  
If the base API cannot express a subtype invariant safely, the subtype ends  
up fighting the API.  

Example:  

```js
export class DeliveryWindow {
  constructor(startDay, endDay) {
    this.startDay = startDay
    this.endDay = endDay
  }

  setStartDay(startDay) {
    this.startDay = startDay

    return this
  }

  setEndDay(endDay) {
    this.endDay = endDay

    return this
  }
}

export class SameDayWindow extends DeliveryWindow {
  constructor(day) {
    super(day, day)
  }

  setStartDay(day) {
    this.startDay = day
    this.endDay = day

    return this
  }

  setEndDay(day) {
    this.startDay = day
    this.endDay = day

    return this
  }
}

export const delayStartDay = (window, day) =>
  window.setStartDay(day)
```

Callers that rely on `setStartDay` changing only the start
will be surprised by `SameDayWindow`.

#### Enforce substitutability

Write one shared contract test for the seam, and run it against every implementation.  

- Treat the seam contract as enforceable, not aspirational.  
- Use one shared expectation set that every rule must satisfy.  

```js
export const assertPricingRuleContract = (rule, context) => {
  const snapshot = JSON.stringify(context)

  const nextTotalCents =
    rule.apply(context.subtotalCents, context)

  if (!Number.isInteger(nextTotalCents) || nextTotalCents < 0)
    throw new TypeError(
      `Expected integer cents, got ${nextTotalCents}`
    )

  if (JSON.stringify(context) !== snapshot)
    throw new Error('Rule mutated context')
}

for (const rule of rules)
  assertPricingRuleContract(rule, context)
```


## Error handling

Strategies for errors, validation, and input normalization.  

### Avoid defensive programming

Do not paper over broken call sites with internal guards;
keep invariants real and back them with tests.

- Trust internal invariants.  
- If you cannot, write tests.  
- Do not litter internal code with defensive guards.  

- Guards are fine for valid bailouts in procedures.  
- Do not use guards to hide broken call sites.  

Exception: validate external data at boundaries.  

```js
// ✅ Trust internal functions
const process = data => data.filter(active).map(normalize)

// ❌ Defensive programming within internal functions
const processDefensive = data => {
  if (!data || !Array.isArray(data)) return []
  return data
    .filter(i => i && active(i))
    .map(i => (i ? normalize(i) : null))
    .filter(Boolean)
}

// ❌ Defensive early returns
const formatNameDefensive = (first, last) => {
  if (!first) return ''
  if (!last) return ''
  return `${first} ${last}`
}

// ✅ Trust the caller
const formatName = (first, last) => `${first} ${last}`
```

### Use appropriate error types

Choose error types deliberately and keep messages short, precise, and consistent.  

#### Choose the right error class

Pick an error class based on what went wrong, not where you are in the code.  

- wrong type: `TypeError`  
- out of bounds: `RangeError`  
- everything else: `Error` with a clear message (include relevant values)  

```js
if (typeof value !== 'number')
  throw new TypeError(
    `Expected number, got ${typeof value}`
  )

if (value < 0 || value > 100)
  throw new RangeError(`Value ${value} must be 0 - 100`)

if (elapsedMs > timeoutMs)
  throw new Error(`Exceeded ${timeoutMs} ms timeout`)
```

#### Make messages concise and precise

Be short, but never vague.  

- Use the shortest template that stays actionable.  
- Include concrete values when they matter.  

```js
throw new Error(`Exceeded ${timeoutMs} ms timeout`)
throw new Error(`Expected ISO date, got ${input}`)
```

#### Define message templates upfront

Define a tiny set of message formats so related errors read as a uniform system.  

- missing required value: `missing <NAME>`  
- expectation mismatch: `Expected <expected>, got <actual>`  
- invalid transition: `Cannot <verb> a <state> <entity>`  
- timeout/limit: `Exceeded <limit> ms timeout`  

```js
throw new TypeError('missing API_KEY')
throw new Error(`Cannot submit a ${state} order`)
throw new Error(`Exceeded ${timeoutMs} ms timeout`)
```

#### Prefer domain terms over synonyms

Use one domain term per state and stick to it.  

- If your domain says "settled", do not also say "paid".  
- Prefer `Invoice already settled` over `Invoice has already been paid`.  

```js
throw new Error('Invoice already settled')
throw new Error('Invoice has already been paid')
```

#### Keep related operations uniform

Use one message template across similar operations so the system reads predictably.  

```js
// ✅ uniform template across operations
submit() {
  if (this.#state !== 'draft')
    throw new Error(`Cannot submit a ${this.#state} order`)

  // ...
}

cancel() {
  if (this.#state !== 'draft')
    throw new Error(`Cannot cancel a ${this.#state} order`)

  // ...
}

// ❌ inconsistent phrasing
submit() {
  if (this.#state !== 'draft')
    throw new Error(`Cannot submit a ${this.#state} order`)

  // ...
}

cancel() {
  if (this.#state !== 'draft')
    throw new Error(`Transition blocked for ${this.#state} order`)

  // ...
}
```

### Normalize & validate external input

Users add spaces.  
Environment variables arrive as strings.  

Clean everything at the borders.  

```js
// ✅ Environment variables
const port = parseInt(process.env.PORT || '3000', 10)
const env = (process.env.NODE_ENV || 'development')
  .toLowerCase()

// ✅ Booleans
const enabled = /^(true|1|yes|on)$/i.test(
  process.env.ENABLED || ''
)

// ✅ Arrays from CSV
const hosts = (process.env.HOSTS || '')
  .split(',')
  .map(s => s.trim())
  .filter(Boolean)

// ✅ User input
const email = (input || '').trim().toLowerCase()
```

Validation:  

```js
// ✅ Validate at boundaries
const handleRequest = req => {
  if (!req.body?.userId)
    throw new TypeError('missing userId')

  if (typeof req.body.userId !== 'string')
    throw new TypeError(
      `Expected userId string, got ${typeof req.body.userId}`
    )

  return processUser(req.body.userId)
}

// ✅ Early validation
const createUser = data => {
  if (!data.name) throw new TypeError('missing name')
  if (!data.email) throw new TypeError('missing email')
  return save(normalize(data))
}
```

## Testing

Guidelines for the Node.js built-in test runner.  

### Use built-in test runner

Use `node --test`.  
Zero dependencies.  

```js
// ✅ Built-in test runner
// Run with: node --test "**/*.test.js"
import { test } from 'node:test'
```

### Use global hooks via --import

Preload shared setup with `--import` for hooks that run across all test files.  
Place global setup in `test/utils/setup.js`.  

Note: `--import` preloads modules for side effects.  
Use `--test-global-setup` for explicit setup/teardown exports.  

```js
// test/utils/setup.js
import { before, after } from 'node:test'

before(async () => {
  // start server, connect db, etc.
})

after(async () => {
  // cleanup resources
})
```

```bash
node --test --import ./test/utils/setup.js "**/*.test.js"
```

Or use `--test-global-setup` for explicit setup/teardown exports:  

```js
// test/utils/setup.js
export const globalSetup = async () => {
  // runs once before all tests
}

export const globalTeardown = async () => {
  // runs once after all tests
}
```

```bash
node --test --test-global-setup=./test/utils/setup.js "**/*.test.js"
```

Setup errors abort the run.  
Teardown is skipped if setup fails.  

### Propagate errors and set timeouts

Hanging tests are worse than failing tests.

- `--test-timeout=<ms>` sets per-test timeout (default: Infinity).
- Exit on unhandled errors; never swallow silently.
- Prefer short timeouts; long waits hide real problems.
- Use `timeout <secs> <cmd>` when running tests in CI.

```js
// test/utils/setup.js
import { before, after } from 'node:test'

process.on('unhandledRejection', err => {
  console.error('Unhandled rejection:', err)
  process.exit(1)
})

process.on('uncaughtException', err => {
  console.error('Uncaught exception:', err)
  process.exit(1)
})
```

```bash
node --test --test-timeout=5000 "**/*.test.js"
```

### Rely on stable test discovery

Keep the test command stable so adding tests
never requires updating CI or scripts.

- Use one glob that covers co-located tests.
- Avoid narrow paths that miss new test files.

```bash
# ✅ catches everything
node --test "**/*.test.js"

# ❌ misses co-located tests
node --test test/unit/*.test.js
```

`package.json` examples:

```txt
test: node --test "**/*.test.js"
test: node --test --import test/utils/setup.js "**/*.test.js"
```

### Structure tests hierarchically

Tests tell a story: component → scenario → expectation.  
Nest them that way.  

```js
// ✅ Hierarchical structure
test('#withdraw', async t => {
  await t.test('amount within balance', async t => {
    await t.test('disperses requested amount', async t => {
      // assertion with await
    })
  })

  await t.test('amount exceeds balance', async t => {
    await t.test('throws appropriate error', async t => {
      // assertion with await
    })
  })
})
```

### Write focused tests

One test, one assertion, one failure reason.  

```js
// ✅ Granular tests
test('#withdraw', async t => {
  t.beforeEach(t => (t.atm = new ATM(100)))

  await t.test('returns updated balance', async t => {
    t.assert.strictEqual(await t.atm.withdraw(30), 70)
  })
})
```

### Attach fixtures to test context

Attach test data directly to the context using  
`t.beforeEach(t => t.atm = new ATM(100))`.  

Avoid external variables or imports for fixtures.  

```js
// ✅ Context fixtures
test('#withdraw', async t => {
  t.beforeEach(t => (t.atm = new ATM(100)))

  await t.test('disperses amount', async t => {
    await t.atm.withdraw(30)
  })
})
```

### Use context for test utilities

Everything is on `t`: `t.assert`, `t.mock`, `t.beforeEach`.  
`t.mock` resets automatically between tests.  

```js
// ✅ Context utilities
test('#notify', async t => {
  await t.test('sends email', t => {
    const emailer = t.mock.fn()
    notify(user, { send: emailer })

    t.assert.strictEqual(emailer.mock.callCount(), 1)
  })
})
```

### Assert the minimum required

Assert only what matters for the behavior under test;
avoid coupling tests to incidental structure.

- Do not test what you do not care about.  
- Avoid asserting entire objects that will grow.  
```js
// ✅ Partial assertions
test('#user properties', async t => {
  t.beforeEach(t => {
    t.user = { name: 'Alice', role: 'admin', extra: 'ignore' }
  })

  await t.test('has correct details', t => {
    t.assert.partialDeepStrictEqual(t.user, {
      name: 'Alice',
      role: 'admin',
    })
  })
})
```

### Test for keywords, not sentences

Match keywords that survive rephrasing.  

Pick keywords unique to the test:  

- ✓ `/insufficient/` - specific to this error  
- ✗ `/balance/` or `/invalid/` - too generic  

```js
// ✅ Flexible matching
test('#withdraw', async t => {
  t.beforeEach(t => (t.atm = new ATM(100)))

  await t.test('exceeds balance', async t => {
    await t.assert.rejects(() => t.atm.withdraw(150), {
      name: 'Error',
      message: /insufficient/i,
    })
  })

  await t.test('preserves balance', async t => {
    await t.atm.withdraw(150).catch(() => null)
    t.assert.strictEqual(t.atm.balance, 100)
  })
})
```

Complete test example:  

```js
test('#atm', async t => {
  t.beforeEach(t => (t.atm = new ATM(100)))

  await t.test('#withdraw', async t => {
    await t.test('within balance', async t => {
      await t.test('returns updated balance', async t => {
        t.assert.strictEqual(await t.atm.withdraw(30), 70)
      })
    })

    await t.test('exceeds balance', async t => {
      await t.test('throws error', async t => {
        await t.assert.rejects(() => t.atm.withdraw(150), {
          name: 'Error',
          message: /insufficient/i,
        })
      })

      await t.test('preserves balance', async t => {
        await t.atm.withdraw(150).catch(() => null)
        t.assert.strictEqual(t.atm.balance, 100)
      })
    })
  })

  await t.test('#properties', async t => {
    await t.test('has location and currency', t => {
      t.assert.partialDeepStrictEqual(t.atm, {
        location: 'Main Street',
        currency: 'USD',
      })
    })
  })
})
```

## Documentation

> technical documentation guidelines  

### Philosophy

Write docs that are scannable and low-noise.  

- scannable at a glance  
- get to the point fast  
- strip noise and repetition  

Example:  

```md
## Refunds

Refunds require an order id.  
Refunds are idempotent.  
Refunds create a ledger entry.  
```

### Use structured headings

Headings should read like an index.  

Rules:  

- Start with a single `#` title naming the scope.  
- Keep headings 1–10 words.  
- Prefer verbs (Use/Prefer/Avoid/Never) for rule sections.  
- Use nouns for reference sections.  
- Prefer simple patterns: `[Verb] [Subject]`, `X instead of Y`, `If X, do Y`.  
- Never place a heading directly after a heading.  
  Always include at least one non-heading context line after each heading.  
  Exception: reference sections with obvious content.  
- One empty line before and after each heading.  

```md
<!-- ❌ verbose heading, heading after heading, no context line -->
# Payments module

## How to process refunds in the system
## Errors
- This is a list with no context line for the section.

<!-- ✅ short heading, context line after each heading -->
# Payments

## Process refunds

Refunds require an order id and a reason code.

## Errors

- `RangeError` for invalid amounts.
- `TypeError` for invalid types.
```

### Break new sentences into newlines

One sentence per line makes diffs cleaner and nudges you toward concise prose.  

- Start each sentence on its own line for cleaner diffs.  
- End each prose line with two spaces to force a hard line break.  
- Keep sentences ≤20 words; active voice; neutral tone; no filler.  

```md
Lorem ipsum dolor sit amet.  
Consectetur adipiscing elit.  
Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.  
```

### Prefer to break into newline

Wrap by meaning, not by character count,
so paragraphs remain readable without relying on
editor soft-wrap.

- Break at semantic boundaries (punctuation, clauses, logical units).  
- Do not wrap purely to satisfy a character count.  
- Do not rely on editor soft wrap.  
- Aim for ~80 chars; treat ~90 chars as a hard max.  

Rules:  

- Break at spaces or punctuation.  
- Never split words.  
- Never split text inside parens or backticks.  

```md
<!-- ❌ breaks mid-clause -->
The `--import` flag loads global test hooks, but you still need to set
timeouts and propagate errors.

<!-- ✅ breaks at the clause boundary -->
The `--import` flag loads global test hooks,
but you still need to set timeouts and propagate errors.
```

### Use consistent Markdown primitives

Use a small set of Markdown constructs and keep them consistent.  

Links:  

- Prefer reference-style links; keep URLs at the end of the document.  

Code:  

- Use language tags on fenced blocks.  
- Use backticks inline for code, commands, paths, and filenames.  

Lists:  

- Bullets for enumeration.  
- Numbered lists for stepped procedures.  

Tables:  

- Align columns.  

Labels:  

- Use `**Label:**` pseudo-headers to make sections scannable.  
- One empty line before and after pseudo-headers.  
- Use `**❌:**` and `**✅:**` only in style guides.  

````md
**Install:**

```bash
npm test
```

See [Node.js docs][node].  

[node]: https://nodejs.org/
````

### Template

README structure for Node.js packages.  

````md
# [Project Name]

[![test][testb]][test]

[1-3 word description, e.g., "web server"]

```bash
npm i author/repo
```

## [Verb] [subject]

[Context line without repeating header]

**[Label]:**

```js
// code example
```

## [Verb] [subject]

[Context line without repeating header]

1. [First step]
2. [Second step]
   1. [Nested substep]
   2. [Nested substep]
3. [Third step]

```js
// code example for workflow
```

```js
// concise example
```

## Run tests

```bash
npm test
```

## License

[MIT][li-spdx]

[testb]: https://github.com/user/repo/actions/workflows/test.yml/badge.svg
[test]: https://github.com/user/repo/actions/workflows/test.yml
[li-spdx]: https://opensource.org/licenses/MIT
[link-ref]: https://example.com
````

### Style guide template

Pattern-based guides with examples.  

````md
# [Style Guide Name]

[Short description of this guide]

## [Category]

[Context about this category]

### [Topic]

[One-line principle.]

**❌: [Anti-Pattern]**

[Why it's bad.]

```[lang]
// bad example
```

**✅: [Pattern]**

[When to use.]

```[lang]
// good example
```

**✅: [Pattern]**

[When to use.]

```[lang]
// good example
```
````

> [!WARNING]  
> **Author constraint:** Never invent or list features or requirements  
> unless explicitly requested in the prompt or spec.  

## HTML/Markup

Minimal HTML/CSS for simple pages.  

### Principles

Principles for small pages.  
Prefer modern, native, classless, accessible defaults.  

- **Semantic:** Use `main`, headings, focus states, and good contrast.  
- **Classless:** Use element selectors; add classes only when needed.  
- **Fluid:** Use `80ch`, `rem`, and a ratio scale via `pow()`.  
- **Native:** Use `color-scheme`, `light-dark()`, and system fonts.  
- **Modern:** Use nesting, `pow()`, `text-wrap`, and `light-dark()`.  

```html
<main>
  <h1>Orders</h1>

  <section aria-labelledby="refunds">
    <h2 id="refunds">Refunds</h2>
    <p>Refunds require an order id.</p>
  </section>
</main>
```

### Headings

Use headings for structure, not styling.  

Rules:  

- one `h1` per page  
- do not skip levels (`h2` → `h3`, not `h2` → `h4`)  
- headings should label sections, not decorate layouts  
- keep heading text short and concrete  

**❌:** Skips a level.  

```html
<h1>Orders</h1>
<h2>Refunds</h2>
<h4>API</h4>
```

**✅:** Uses consecutive levels.  

```html
<h1>Orders</h1>
<h2>Refunds</h2>
<h3>API</h3>
```

### Boilerplate

A minimal, classless HTML template with modern CSS.  

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta name="description" content="dolor sit amet.">
  <title>Lorem Ipsum</title>
  <link rel="icon" href="https://fav.farm/🪜"/>

  <style>
  :root {
    color-scheme: light dark;

    --ratio: 1.25;

    --bg:      light-dark(#ffffff, #0b0b0c);
    --text:    light-dark(#111111, #e6e6e6);
    --accent:  light-dark(#0b57d0, #8ab4f8);
    --tertiary: light-dark(#7c3aed, #c4b5fd);

    --font-ui: system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI",
      Roboto, Helvetica, Arial, sans-serif;
    --font-prose: ui-serif, Georgia, Cambria, "Times New Roman", Times, serif;
  }

  body {
    margin:      0;
    background:  var(--bg);
    color:       var(--text);
    font-family: var(--font-prose);
    font-size:   0.9rem;
    line-height: 1.6;
  
    a {
      color: var(--accent);
      &:hover { color: var(--tertiary); }
      &:focus-visible {
        outline:        2px solid var(--accent);
        outline-offset: 2px;
      }
    }
  
    main { max-width: 80ch; margin: 2rem auto; padding: 0 1rem; }
  
    h1, h2, h3, h4, h5, h6 {
      font-family:   var(--font-ui);
      font-weight:   500;
      line-height:   1.2;
      margin-bottom: .5em;
      text-wrap:     balance;
    }
  
    p { text-wrap: pretty; }
  
    h1 { font-size: calc(1rem * pow(var(--ratio), 3)); margin-top: 2em;     }
    h2 { font-size: calc(1rem * pow(var(--ratio), 2)); margin-top: 1.75em;  }
    h3 { font-size: calc(1rem * var(--ratio));         margin-top: 1.5em;   }
    h4, h5, h6 { font-size: 1rem;                      margin-top: 1em;     }
  
    h1:first-child { margin-top: 0; }
  }
  </style>
</head>

<body>
  <main>
    <h1>Less, but better</h1>
    <p>
      Good design is <a href="#">as little design as possible</a>. Less, but
      better—because it concentrates on the essential aspects, and the products
      are not burdened with non-essentials.
    </p>

    <p>
      Minimalism isn't the absence of detail—it's the absence of the unnecessary.
      What remains must be considered exhaustively. Every margin, every weight,
      every pixel earns its place or gets cut.
    </p>
    
    <blockquote>
      <p>Good design is thorough down to the last detail.</p>
      <cite>— <a href="https://www.vitsoe.com/gb/about/dieter-rams">Dieter Rams</a></cite>
    </blockquote>
    
    <h2>Clarity</h2>
    <p>
      Typography exists to honor content. A well-set page invites the reader in
      and makes the act of reading effortless. The best interface is one you
      don't notice.
    </p>
    
    <h3>Hierarchy</h3>
    <p>
      Scale creates rhythm. Consistent ratios between heading levels guide the
      eye naturally through content, establishing importance without shouting.
    </p>
  </main>
</body>
</html>
```

[author]: https://github.com/nicholaswmin
