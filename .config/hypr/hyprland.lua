local modules = {
    "matugen",
    "vars",
    "general",
    "plugins",
    "env",
    "execs",
    "keybindings",
    "animations",
    "rules",
    "custom",
}

for _, module in ipairs(modules) do
    package.loaded[module] = nil
end

for _, module in ipairs(modules) do
    require(module)
end
