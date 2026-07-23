# examples/minimal-web-stack

Standalone example showing how to consume the terraform-aws-modules directly
from the public registry (not via this repo's local `modules/`) — a copy-paste
starting point for a new project that doesn't want a dependency on this repo at
apply time.

**Status:** placeholder — will be filled in after `modules/*` and `envs/dev` are
implemented, so it can mirror a working configuration rather than diverge from
one.

Unlike `envs/dev`/`envs/prod`, this example intentionally does **not** reference
`../../modules/*` by local path — every `source` here should point straight at
`terraform-aws-modules/<name>/aws` on the public registry, since the whole point
is that this directory is self-sufficient to copy elsewhere.
