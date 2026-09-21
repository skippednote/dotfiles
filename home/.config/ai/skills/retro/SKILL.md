---
name: retro
description: "Retrospect on the current session: reconstruct the route actually taken to reach this point, separate the essential steps from the waste, and derive the shortest route that would have reached the same verified endpoint. Use only when explicitly asked - /retro, or a question like 'how could we have gotten here faster', 'what went wrong in this session', 'could this have been shorter'. Never run unprompted, and never as a substitute for finishing the task at hand."
---

# Retro

Analyse the session you are in. The input is the conversation so far, not a
file on disk. Produce a critique of the route and a shorter route, both
grounded in specific steps that actually happened.

This is read-only. Propose fixes; do not apply them. If the user wants a fix
applied, they will say so in a following message.

## Before writing anything

Establish three things.

**The endpoint.** What state does the session currently sit in - what is
built, verified, decided? A retro of an unfinished task retrospects on the
part that is finished; say so rather than speculating about the remainder.

**The goal, as finally understood.** One line. Use the understanding you have
now, not the one you started with. The gap between the two is usually the
single largest source of waste.

**What a step cost.** Two units, and they are not comparable:

- a **tool call** - cheap, a few seconds
- a **user turn** - expensive; the session stops until a human reads, thinks
  and replies

Any step that forced the user to answer a question, correct a wrong
direction, or re-approve a revised plan cost a user turn. Rank findings by
total cost with user turns weighted an order of magnitude above tool calls.
A single avoidable user turn outranks a handful of redundant greps.

## Output

Six sections, in this order, in the user's terminal. No preamble.

Length follows the findings. If fewer than three findings survive section 3's
cost filter, emit only sections 1, 3 and 5 and keep the whole thing under a
screen. Padding a clean session into six sections is its own waste.

### 1. Goal

One line: what this session was actually for, as understood now.

### 2. Route taken

A numbered timeline of what happened. A plain list, one line per step - no
tables. Tag each step:

- `essential` - on the shortest path; would appear in any correct route
- `avoidable` - produced something useful, but a cheaper step existed
- `detour` - produced nothing that survived into the endpoint
- `rework` - redid or undid earlier work in this same session

Collapse runs of similar or repeated steps into one line with a count ("3
calls fighting the same truncated output"). Several attempts at one thing are
one step, and writing them separately hides the pattern that makes them a
finding.

Do not annotate per-step cost. A column of "1 call" carries no signal; cost
belongs on findings, where it is aggregated and compared. The exception is a
step that cost a user turn - mark those, because section 3 ranks by them.

Hard cap: 12 lines. Past that, collapse harder.

### 3. Findings

Root-cause the `avoidable`, `detour` and `rework` steps. Each finding gets:

- the category, from this list
- the step numbers it explains
- its total cost, in tool calls and user turns
- a **knowable** or **only learnable** verdict, on the same line

Categories: **missing context** (information that existed and was not
gathered), **wrong tool** (a slower instrument than the job needed),
**unverified assumption** (acted on a belief, belief was wrong), **ambiguous
instruction** (the prompt supported several readings, wrong one taken), **no
plan** (edited before the shape of the change was known), **needless
serialisation** (independent work run one at a time), **re-derivation**
(re-established something already established).

**Knowable** means the information needed to skip those steps was available
at the start - in the repo, in the prompt, in a readable file, in a question
that could have been asked. **Only learnable** means the path had to be
walked.

Be honest on that verdict. Hindsight makes every wrong turn look obvious; if
a detour was the correct bet given what was known at the time, mark it only
learnable and say so. A retro that blames unavoidable exploration teaches
hesitation instead of a fast probe. If every finding comes out knowable,
distrust that and re-examine - it usually means the endpoint is being used as
evidence that the route to it was predictable.

Ranked by cost, highest first. **At most five, and five is a ceiling, not a
target.** Drop anything under one round trip. A finding that will not earn a
fix in section 5 should not be here at all - carrying one forward to dismiss
it three sections later is ceremony, not analysis. State how many survived.

### 4. Shortest route

The minimal sequence that reaches the same endpoint, verified to the same
standard. Numbered, one line each.

State the preconditions it assumes: the knowable facts from section 3 this
route needs up front.

Then test it: **could this route be derived from those preconditions alone,
without knowing the endpoint?** Walk it forward from turn one and check that
no step depends on a conclusion the session only reached later. A step
justified by "which is obvious once you see X" fails the test when X was the
discovery. Cut or rewrite every step that fails, before quoting a delta.

Close with the delta: `N steps / ~M calls / K user turns, against X / ~Y / Z
taken`. Discount any saving that survived only by assuming the answer. If the
delta is small, say so. Some sessions were already near optimal and knowing
that is the useful result.

### 5. Fixes

For each knowable finding, one durable change that would make the shortest
route the default next time. Each fix names a destination and gives the
literal text to put there:

- a memory file - give the content
- a line in `~/.config/ai/working-preferences.md` or a project `CLAUDE.md` /
  `AGENTS.md` - give the line
- a new or amended skill - name it and give its trigger condition
- a shell alias, script, or hook - give the command
- a README or docs gap - give the section and where it goes

Three rules, all of which reject fixes that otherwise look reasonable:

**Read the destination first.** Open the file you are proposing to edit
before writing text for it. Two files with similar names are often not
interchangeable, and a block that fits one may contradict the other. Never
propose the same text for two destinations without confirming both want it.

**The fix must cost less than the waste, in the general case.** A fix that
generalises to "gather more context up front" or "verify before acting" is
paid on every future session, including the many where it buys nothing, to
avoid a cost paid once here. Price it that way. If it does not clear the bar,
say the finding is not worth a permanent fix - that is a legitimate result,
and the most common one for a single missed read.

**It must be specific enough to paste.** "Read the config first", "be more
careful", "plan before editing" are the finding restated. They change
nothing.

At most three. If a finding is genuinely one-off, propose nothing for it and
say so. A config directory that accretes a line per past mistake is a cost
compounding against every future session.

### 6. What only the user could have said

One or two lines, maximum: the context that lives with the user and nowhere
in the repo - a constraint, a downstream consumer, a preference, a deadline -
which would have redirected the route had it been stated at turn one.

This section is not a better prompt. Do not write the user an implementation
brief; if the shortest route depended on facts you discovered, or on
conventions already visible in their own repo, those are yours to fix in
section 5, and the correct output here is "nothing - this was mine to get
right." Asking the user to hand-hold the next session is a fix that scales
badly and puts the work on the wrong side.

## Rules

- No praise. What worked is implicit in the essential steps.
- No finding without a step number behind it.
- Do not invent steps that did not happen, and do not soften a cost to make
  the route look better than it was.
- Judge the route, not the person. "The prompt was ambiguous" is a finding
  about a prompt, and it applies equally to your own reading of it.
- If the session was short or clean, the correct output is short. Three lines
  saying so beats six padded sections.
