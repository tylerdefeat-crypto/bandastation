// This file contains everything used by security, or in other combat applications.

/obj/item/storage/box/flares
	name = "box of flares"
	desc = "A box with 5 flares."
	icon_state = "security"
	illustration = "flare"

/obj/item/storage/box/flares/PopulateContents()
	for(var/i in 1 to 5)
		new /obj/item/flashlight/flare(src)
