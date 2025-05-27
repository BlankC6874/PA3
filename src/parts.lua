local Parts = {}

-- Define the Parts catalog with different types and their properties
Parts.catalog = {
    chassis = {
        light = {speed = 2, armor = 1},
        heavy = {speed = 1, armor = 3},
    },
    tool = {
        cutter = {action = "cut"},
        solder = {action = "repair"},
        emp = {action = "stun"},
    },
    chip = {
        basic = {autoNav = false},
        navChip = {autoNav = true},
    }
}

return Parts