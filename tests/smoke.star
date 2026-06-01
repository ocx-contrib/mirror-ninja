# Stable smoke test — assert on the contract (exit code, version shape,
# env-var honoring), never on help/version prose. Ninja's banner and help
# text are upstream's to reword; the version digits, a successful build, and
# the NINJA_STATUS prefix it prints are the contract.
NINJA = "ninja.exe" if ocx.target_platform.os == ocx.os.Windows else "ninja"

# Tier 1 + 2: liveness + version SHAPE (ninja prints a bare semver to stdout).
r_version = ocx.run(NINJA, "--version")
expect.ok(r_version)
expect.matches(r_version.stdout, r"\d+\.\d+\.\d+")

# Tier 3 + 4: functional build on a hermetic build.ninja, with NINJA_STATUS
# set to a custom prefix. A `command`-bearing rule (true / cmd /c exit 0) makes
# ninja print one status line; honoring NINJA_STATUS means the custom prefix
# appears in stdout — proving both the build engine runs and the env var wires.
NOOP_CMD = "cmd /c exit 0" if ocx.target_platform.os == ocx.os.Windows else "true"
ocx.write_file("build.ninja", "rule noop\n  command = " + NOOP_CMD + "\nbuild stage: phony\nbuild all: noop stage\n")

STATUS_PREFIX = "OCXSMOKE> "
r_build = ocx.run(NINJA, "all", env={"NINJA_STATUS": STATUS_PREFIX})
expect.ok(r_build)
expect.contains(r_build.stdout, STATUS_PREFIX)
