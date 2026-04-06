// This file contains everything used by security, or in other combat applications.

/obj/item/storage/box/flares
	name = "box of flares"
	desc = "A box with 5 flares."
	illustration = "flare"

/obj/item/storage/box/emps/PopulateContents()
	for(var/i in 1 to 5)
		new /obj/item/flashlight/flare(src)
