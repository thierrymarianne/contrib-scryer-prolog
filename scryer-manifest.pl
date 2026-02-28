name("scryer-zenroom").

% Main entry point for the package
main_file("lib/zenroom.pl").

% License information
license(name("BSD-3-Clause"), path("./LICENSE")).

% Package metadata
version("0.1.0").
author("Thierry Marianne").
description("Zenroom cryptographic operations integration for Scryer Prolog via FFI").
homepage("https://github.com/yourusername/scryer-zenroom").

% No Prolog dependencies (only native Zenroom library)
dependencies([]).

% Native dependencies (informational - not automatically resolved)
% Users must build/install Zenroom library manually or via justfile
native_dependencies([
    native_dep("zenroom", 
        source(git("https://github.com/dyne/Zenroom.git")),
        build_instructions("Run: just install-zenroom-macos or just install-zenroom-linux"))
]).
