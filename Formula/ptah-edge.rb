# This formula is written by hand and is NOT generated.
#
# GoReleaser owns Formula/ptah.rb and rewrites it on every release tag. It
# writes that one path and nothing else, so this file survives a release --
# but it also means nothing regenerates it. When the build in
# .goreleaser.yaml changes (ldflags, CGO, the set of binaries), change it here
# too, or the edge build stops matching the release it is the edge of.
class PtahEdge < Formula
  desc "Database change across schemas and persistent inference state, built from master"
  homepage "https://github.com/stokaro/ptah"
  license "MIT"
  head "https://github.com/stokaro/ptah.git", branch: "master"

  depends_on "go" => :build

  # Not conflicts_with. Homebrew loads the named formula to evaluate a
  # conflict, and `brew install <tap>/<formula>` trusts only the formula it was
  # given, so declaring one here made `brew install --HEAD stokaro/ptah/ptah-edge`
  # fail on an untrusted tap with "Refusing to load formula stokaro/ptah/ptah".
  # Measured on Homebrew 6.0.20; it broke both directions at once. A caveat is a
  # string and loads nothing.
  def caveats
    "ptah installs the same three binaries from the newest release. Install only
one of the two: brew uninstall ptah before installing this one."
  end


  def install
    # The release build sets this, and ptah's SQLite driver is modernc.org/sqlite,
    # which is pure Go. Leaving cgo on would build a different binary than the
    # one a release ships.
    ENV["CGO_ENABLED"] = "0"

    ldflags = %W[
      -s -w
      -X ptah.run/internal/buildinfo.Version=#{version}
      -X ptah.run/internal/buildinfo.Commit=#{Utils.git_head}
      -X ptah.run/internal/buildinfo.Date=#{time.iso8601}
    ]

    %w[ptah ptah-compat ptah-ls].each do |cmd|
      system "go", "build", *std_go_args(ldflags: ldflags, output: bin/cmd), "./cmd/#{cmd}"
    end
  end

  test do
    # A build whose ldflags went missing still runs, and answers "dev" and
    # "unknown". Asserting the stamped values are present, and the defaults
    # absent, is what separates the two. Utils.git_head is deliberately not
    # used here: no source is staged during a test, so it would read whatever
    # repository the test happens to run inside.
    %w[ptah ptah-compat].each do |cmd|
      output = shell_output("#{bin}/#{cmd} version")
      assert_match(/^Version: \S+/, output)
      refute_match "Version: dev", output
      refute_match "Commit: unknown", output
    end

    output = shell_output("#{bin}/ptah-ls --version")
    assert_match(/^Version: \S+/, output)
    refute_match "Version: dev", output
  end
end
