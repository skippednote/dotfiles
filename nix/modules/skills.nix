# Links the skills listed in nix/skills.nix out of their pinned flake inputs.
#
# Unlike the rest of home.file these are store paths, not out-of-store links:
# nothing writes to a third-party skill, and a read-only copy is what keeps it
# at the locked revision. Each skill is linked as a directory, one per name,
# because ~/.claude/skills also holds skills the tools install themselves.
{ lib, inputs, ... }:

let
  entries = import ../skills.nix;

  skillsOf =
    entry:
    let
      src =
        inputs.${entry.input}
          or (throw "nix/skills.nix: no flake input named ${entry.input}; declare it in flake.nix");
      dir = "${src}/${entry.dir or "skills"}";
      isSkill = name: lib.pathExists "${dir}/${name}/SKILL.md";
      names =
        entry.skills or (lib.filter isSkill (
          lib.attrNames (lib.filterAttrs (_: type: type == "directory") (builtins.readDir dir))
        ));
    in
    map (
      name:
      assert
        isSkill name
        || throw "nix/skills.nix: ${entry.input} has no ${entry.dir or "skills"}/${name}/SKILL.md";
      {
        inherit name;
        path = "${dir}/${name}";
      }
    ) names;

  skills = lib.concatMap skillsOf entries;

  # Two entries providing the same name would otherwise surface as a
  # home-manager conflict on the link path, which names neither source.
  dupes = lib.attrNames (
    lib.filterAttrs (_: n: n > 1) (
      lib.foldl' (acc: s: acc // { ${s.name} = (acc.${s.name} or 0) + 1; }) { } skills
    )
  );
in

assert
  dupes == [ ]
  || throw "nix/skills.nix: more than one entry provides ${lib.concatStringsSep ", " dupes}";

{
  home.file = lib.listToAttrs (
    lib.concatMap (s: [
      (lib.nameValuePair ".claude/skills/${s.name}" { source = s.path; })
      (lib.nameValuePair ".codex/skills/${s.name}" { source = s.path; })
    ]) skills
  );
}
