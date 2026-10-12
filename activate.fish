# Usage: source ~/workspace-meta/activate.fish

if not set -q WORKSPACE_META
    set -gx WORKSPACE_META (realpath (status filename | path dirname))
end

set -gx OPENCODE_CONFIG "$WORKSPACE_META/opencode.jsonc"
set -gx OPENCODE_CONFIG_DIR "$WORKSPACE_META/opencode"

# Make workspace scripts available in this shell.
fish_add_path --prepend "$WORKSPACE_META/bin"

# Define deactivation for this environment.
function deactivate --description "Deactivate workspace-meta"
    # fish has no fish_remove_path; fish_add_path --prepend records the dir in
    # the universal $fish_user_paths variable, so remove it from there.
    if set -q fish_user_paths
        set -l index (contains -i -- "$WORKSPACE_META/bin" $fish_user_paths)
        and set -e fish_user_paths[$index]
    end

    set -e OPENCODE_CONFIG
    set -e OPENCODE_CONFIG_DIR
    set -e WORKSPACE_META

    functions -e deactivate
end

echo "Activated workspace-meta: $WORKSPACE_META"
