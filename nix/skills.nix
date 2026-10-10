# Agent skills pulled from other repos, linked into ~/.claude/skills and
# ~/.codex/skills by nix/modules/skills.nix.
#
# To add a repo: declare it in flake.nix as a non-flake input named
# skills-<something>, then add an entry here naming that input. It is
# pinned in flake.lock; `nix flake update skills-<something>` moves it.
#
#   input   the flake input name
#   dir     directory in the repo holding one subdirectory per skill
#           (default "skills")
#   skills  which of those to link; omit to link every one with a SKILL.md
[
  {
    input = "skills-skippednote";
    skills = [ "retro" ];
  }
  {
    input = "skills-herdr";
    skills = [ "herdr" ];
  }
  {
    input = "skills-mattpocock";
    dir = "skills/productivity";
    # grill-me only calls the Skill tool with "grilling".
    skills = [
      "grill-me"
      "grilling"
    ];
  }
  {
    input = "skills-mattpocock";
    dir = "skills/engineering";
    # improve-codebase-architecture calls codebase-design, domain-modeling
    # and grilling (above).
    skills = [
      "improve-codebase-architecture"
      "codebase-design"
      "domain-modeling"
    ];
  }
]
