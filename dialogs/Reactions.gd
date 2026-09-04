extends Node

# Ms Kelly's reaction lines for the submitted color, grouped into likeness
# bands (higher first). Reactions.pick(likeness) returns a random line from
# the first band whose min threshold the likeness reaches, plus the matching
# portrait emotion. DialogueSystem shows it in the same phrase panel used for
# the intro, with the Animal-Crossing voicebox.

const BANDS = [
	{
		"min": 92.0,
		"emotion": "surprised",
		"lines": [
			"[rainbow freq=0.3 sat=.6 val=1.2]WOW!![/rainbow] Are you reading my mind?!",
			"PERFECT!! The customer is speechless!",
			"You must be part hair-dye! That's uncanny!!",
			"Did you steal my color swatches?? Stunning!"
		]
	},
	{
		"min": 85.0,
		"emotion": "smile",
		"lines": [
			"Ooh, look at that shine! The customer is beaming!",
			"Gorgeous!! We'll call this one 'salon magic'.",
			"Now THAT is a professional dye job!",
			"Beautiful!! The roots are history!"
		]
	},
	{
		"min": 70.0,
		"emotion": "smile",
		"lines": [
			"Nice! The customer will definitely leave a tip.",
			"Good enough for the window display!",
			"Solid work. The chair's spinning with joy!",
			"Not bad at all, keep those combs flying!"
		]
	},
	{
		"min": 50.0,
		"emotion": "neutral",
		"lines": [
			"Eh... close-ish. The customer is squinting.",
			"Let's say the mirror is being very kind today.",
			"It's a look. Not the look, but a look.",
			"Halfway there! The other half is still pale."
		]
	},
	{
		"min": 25.0,
		"emotion": "cry",
		"lines": [
			"Oh dear... the customer is pretending not to cry.",
			"That's... creative. Very creative.",
			"Ms Kelly, is this what regret smells like?",
			"We might need a bigger hat to cover that."
		]
	},
	{
		"min": -999.0,
		"emotion": "cry",
		"lines": [
			"[shake rate=6 level=10]WHAT DID YOU DO?![/shake]",
			"The customer fainted. THE CUSTOMER FAINTED.",
			"Even the plants are wilting!!",
			"That's not a dye, that's a cry for help!!"
		]
	}
]

func pick(likeness: float) -> Dictionary:
	var band: Dictionary = BANDS[BANDS.size() - 1]
	for b in BANDS:
		if likeness >= float(b["min"]):
			band = b
			break
	var lines: Array = band["lines"]
	var text: String = lines[randi() % lines.size()]
	var pitch: float = 2.0 + randf() * 0.8
	return {"text": text, "emotion": band["emotion"], "pitch": pitch}
