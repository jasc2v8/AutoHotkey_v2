if ($args.Count -eq 0) {
    return
}

foreach ($arg in $args) {
    Write-Output "Arg: $arg"
}