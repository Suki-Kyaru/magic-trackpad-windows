# OSS-1.3A Upstream License / Corresponding-Source Evidence

This phase freezes upstream provenance before making any repository-license
decision.

Key finding:

The v2.0 signed release asset is not safely described merely as "built from the
v2.0 tag".

The release points to Actions run 22308909844. The workflow revision
3611b8c6f4fa06a6912d16bb4b51a47bb8c70afa explicitly checks out the `ossign`
branch, creates a source tarball, then builds.

Archived Actions metadata names the generated source artifact:

```text
source-code-8874eaa3994f0e7e40fa40312250bbc5f13cc928
```

So the compliance baseline now distinguishes:

- exact source checkout SHA;
- workflow SHA;
- v2.0 tag SHA.

No LICENSE was added to this wrapper repository in OSS-1.3A.

No runtime/build/driver behavior changed.
