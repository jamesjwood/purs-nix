#!/usr/bin/env bash
# lock-package-set.sh - Generate locked Nix package set from JSON package set
#
# Usage:
#   lock-package-set.sh <URL> [output-file]
#   lock-package-set.sh --refresh <locked-file>

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
log_info() {
    echo -e "${BLUE}==>${NC} $1" >&2
}

log_success() {
    echo -e "${GREEN}==>${NC} $1" >&2
}

log_warn() {
    echo -e "${YELLOW}Warning:${NC} $1" >&2
}

log_error() {
    echo -e "${RED}Error:${NC} $1" >&2
}

# Check dependencies
check_dependencies() {
    local missing=()
    for cmd in curl jq git; do
        if ! command -v "$cmd" &> /dev/null; then
            missing+=("$cmd")
        fi
    done

    if [ ${#missing[@]} -gt 0 ]; then
        log_error "Missing required commands: ${missing[*]}"
        log_info "Please install: ${missing[*]}"
        exit 1
    fi
}

# Resolve git tag to commit hash
resolve_git_tag() {
    local repo="$1"
    local tag="$2"
    local ref="refs/tags/${tag}"

    # Try to resolve the tag
    local result
    result=$(git ls-remote "$repo" "$ref" 2>/dev/null | head -1 | awk '{print $1}')

    if [ -z "$result" ]; then
        # Maybe it's a branch or commit?
        log_warn "Tag '$tag' not found in $repo, trying as-is..."
        result=$(git ls-remote "$repo" "$tag" 2>/dev/null | head -1 | awk '{print $1}')
    fi

    if [ -z "$result" ]; then
        log_error "Could not resolve '$tag' in $repo"
        return 1
    fi

    echo "$result"
}

# Generate locked package set
generate_locked_set() {
    local url="$1"
    local output="${2:--}"  # Default to stdout if not specified

    log_info "Fetching package set from: $url"
    local json
    json=$(curl -fsSL "$url")

    log_info "Parsing package set..."
    local package_count
    package_count=$(echo "$json" | jq 'length')
    log_info "Found $package_count packages"

    # Start generating Nix expression
    {
        echo "# Generated from: $url"
        echo "# Generated at: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
        echo "# To refresh: nix run github:purs-nix/purs-nix#refresh-package-set -- <this-file>"
        echo "#"
        echo "# This file contains locked package versions with commit hashes"
        echo "# for reproducible, pure evaluation builds."
        echo ""
        echo "self: {"

        # Process each package
        local count=0
        local failed=()
        for package in $(echo "$json" | jq -r 'keys[]'); do
            count=$((count + 1))
            log_info "[$count/$package_count] Processing $package..."

            local repo version deps
            repo=$(echo "$json" | jq -r ".\"$package\".repo")
            version=$(echo "$json" | jq -r ".\"$package\".version")
            deps=$(echo "$json" | jq -c ".\"$package\".dependencies")

            # Resolve tag to commit hash
            local commit
            if commit=$(resolve_git_tag "$repo" "$version"); then
                log_success "  Resolved $version -> ${commit:0:12}..."

                # Convert JSON array to Nix list format
                # JSON: ["a","b","c"] -> Nix: [ "a" "b" "c" ]
                local nix_deps
                nix_deps=$(echo "$deps" | jq -r '. | map("\"" + . + "\"") | join(" ")')

                # Generate Nix entry
                echo "  \"$package\" = {"
                echo "    src.git = {"
                echo "      repo = \"$repo\";"
                echo "      rev = \"$commit\";  # Resolved from tag $version"
                echo "    };"
                echo "    info = {"
                echo "      version = \"$version\";"
                echo "      dependencies = [ $nix_deps ];"
                echo "    };"
                echo "  };"
                echo ""
            else
                log_warn "  Failed to resolve $package, skipping..."
                failed+=("$package")
            fi
        done

        echo "}"

        # Report failures
        if [ ${#failed[@]} -gt 0 ]; then
            log_warn ""
            log_warn "Failed to resolve ${#failed[@]} packages:"
            for pkg in "${failed[@]}"; do
                log_warn "  - $pkg"
            done
            log_warn ""
            log_warn "These packages were omitted from the locked set."
        fi

    } > "$output"

    if [ "$output" != "-" ]; then
        log_success "Locked package set written to: $output"
        log_info "Successfully locked $((count - ${#failed[@]}))/$package_count packages"
    fi
}

# Refresh an existing locked package set
refresh_locked_set() {
    local locked_file="$1"

    if [ ! -f "$locked_file" ]; then
        log_error "File not found: $locked_file"
        exit 1
    fi

    log_info "Reading source URL from $locked_file..."
    local url
    url=$(grep "^# Generated from:" "$locked_file" | sed 's/^# Generated from: //')

    if [ -z "$url" ]; then
        log_error "Could not find source URL in $locked_file"
        log_info "Make sure the file was generated by this tool"
        exit 1
    fi

    log_info "Refreshing from: $url"

    # Generate to a temp file first
    local temp_file="${locked_file}.new"
    generate_locked_set "$url" "$temp_file"

    # Show diff if possible
    if command -v diff &> /dev/null; then
        log_info ""
        log_info "Changes:"
        if diff -u "$locked_file" "$temp_file" || true; then
            log_info "No changes detected"
        fi
        log_info ""
    fi

    # Replace original file
    mv "$temp_file" "$locked_file"
    log_success "Refreshed: $locked_file"
}

# Main script
main() {
    check_dependencies

    if [ $# -lt 1 ]; then
        echo "Usage:"
        echo "  Generate: $0 <package-set-url> [output-file]"
        echo "  Refresh:  $0 --refresh <locked-file>"
        echo ""
        echo "Examples:"
        echo "  $0 https://raw.githubusercontent.com/purerl/package-sets/erl-0.15.3-20220629/packages.json packages.nix"
        echo "  $0 --refresh packages.nix"
        exit 1
    fi

    if [ "$1" = "--refresh" ]; then
        if [ $# -lt 2 ]; then
            log_error "--refresh requires a file argument"
            exit 1
        fi
        refresh_locked_set "$2"
    else
        generate_locked_set "$1" "${2:--}"
    fi
}

main "$@"
