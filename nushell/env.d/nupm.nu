$env.NUPM_HOME = ($nu.default-config-dir | path join "nupm")

$env.NU_LIB_DIRS = ($env.NU_LIB_DIRS | append ($env.NUPM_HOME | path join "modules"))

$env.PATH = (
    $env.PATH
        | split row (char esep)
        | prepend ($env.NUPM_HOME | path join "scripts")
        | uniq
)
